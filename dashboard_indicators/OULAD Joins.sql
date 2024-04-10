# prep for dashboard by exploring possible key performance indicators

# 1: exploring proficiency and competency indicators
	# average scores for passed and failed tests
	# attempts at an assessment before passing

# generate average attempt per assessment before passing to see if assessments are too difficult
# checking if there is usually more than one attempt at an assessment before passing
# there is only one attempt per assessment recorded so average attempts indicator not possible
SELECT id_student, COUNT(id_assessment)
FROM OULAD.assessment_results
LEFT JOIN OULAD.assessments
USING (id_assessment)
GROUP BY id_student, id_assessment
HAVING COUNT(id_assessment) > 1;

# generate average score per assessment and assessment type to see if students achieve proficiency
# possibly compare to industry benchmarks
SELECT 
	ROUND(AVG(temp_table.avg_score),2) AS overall_avg_score, 
    MAX(temp_table.avg_score) AS max_avg_score, 
    MIN(temp_table.avg_score) AS min_avg_score
FROM (
    SELECT code_module, code_presentation, id_assessment, ROUND(AVG(score),2) AS avg_score
    FROM OULAD.assessment_results
    LEFT JOIN OULAD.assessments USING (id_assessment)
    GROUP BY code_module, code_presentation, id_assessment
) AS temp_table;

# generate average score per assessment type to see if students achieve proficiency
SELECT 
    assessment_type,
    ROUND(AVG(temp_table.avg_score), 2) AS overall_avg_score,
    MAX(temp_table.avg_score) AS max_avg_score,
    MIN(temp_table.avg_score) AS min_avg_score
FROM (
    SELECT 
        code_module,
        code_presentation,
        id_assessment,
        assessment_type,
        ROUND(AVG(score), 2) AS avg_score
    FROM OULAD.assessment_results
    LEFT JOIN OULAD.assessments USING (id_assessment)
    GROUP BY code_module, code_presentation, id_assessment, assessment_type
) AS temp_table
GROUP BY assessment_type;

# check out most difficult assessments by course
# AAA and DDD have the most difficult assessments on average
SELECT code_module, ROUND(AVG(temp_table.avg_score), 2) AS code_module_avg_score
FROM (
    SELECT code_module, code_presentation, id_assessment, AVG(score) AS avg_score
    FROM OULAD.assessment_results
    LEFT JOIN OULAD.assessments USING (id_assessment)
    GROUP BY code_module, code_presentation, id_assessment
) AS temp_table
GROUP BY code_module
ORDER BY code_module_avg_score;

# check out the most difficult assessments
# the most difficult assessments are mostly in module DDD
SELECT code_module, code_presentation, id_assessment, ROUND(AVG(score),2) AS avg_score
FROM OULAD.assessment_results
LEFT JOIN OULAD.assessments USING (id_assessment)
GROUP BY code_module, code_presentation, id_assessment
HAVING avg_score < 65
ORDER BY avg_score;

# 2: explore course performance indicators
	# courses with low completion rate ( CR = total credits completed/ total credits possible )
	# courses taking too long (too arduous) or too short to complete (causing boredom)
    
# explore completion rate per module
# possibly compare to industry benchmarks
SELECT code_module, ROUND((COUNT(CASE WHEN final_result IN ('Pass', 'Distinction', 'Fail') THEN 1 END) / COUNT(final_result)) * 100, 2) AS completion_rate
FROM OULAD.student_info
LEFT JOIN OULAD.courses
USING (code_module, code_presentation)
GROUP BY code_module
ORDER BY completion_rate;

# explore time to completion
# The structure of B and J presentations may differ and therefore it is good practice to analyse the B and J presentations separately.
# First check timing of final assignmentd to see if there is a lot of variation of end times within modules (they are self paced)
SELECT
    code_module, 
    code_presentation,
    ROUND(STDDEV_POP(max_date_submitted),0) AS std_max_date_submitted
FROM (
    SELECT 
        ar.id_student,
        a.code_module, 
        a.code_presentation,
        MAX(ar.date_submitted) AS max_date_submitted
    FROM 
        OULAD.assessment_results AS ar
    LEFT JOIN 
        OULAD.assessments AS a USING (id_assessment)
    LEFT JOIN
        OULAD.student_info AS si USING (id_student)
    WHERE 
        si.final_result = 'Pass' OR si.final_result = 'Distinction'
    GROUP BY 
        ar.id_student, a.code_module, a.code_presentation
) AS joins
GROUP BY 
    code_module, code_presentation;
# time to completion
SELECT completion_dates.code_module, completion_dates.code_presentation, ROUND(average_completion_date) AS ave_time_to_completion, ROUND(average_length) AS average_len, ROUND((average_completion_date - average_length)) AS difference
FROM (
    SELECT code_module, AVG(module_presentation_length) AS average_length
    FROM OULAD.student_info
	# WHERE final_result != 'Withdrawn'
    LEFT JOIN OULAD.courses USING (code_module, code_presentation)
    GROUP BY code_module
) AS temp_table
LEFT JOIN (
    SELECT code_module, code_presentation, AVG(max_date_submitted) AS average_completion_date
    FROM (
        SELECT code_module, code_presentation, id_student, MAX(date_submitted) AS max_date_submitted
        FROM OULAD.assessment_results
        LEFT JOIN OULAD.assessments USING (id_assessment)
        GROUP BY code_module, code_presentation, id_student
    ) AS subquery
    GROUP BY code_module, code_presentation
) AS completion_dates
ON completion_dates.code_module = temp_table.code_module
ORDER BY difference;


# 3: explore engagement indicators
# Engagement ties into other important metrics such as knowledge retention, competency, and whether or not the learning objectives are achieved. If your learners are not engaged (low percentage of enrollment and completed courses) then you’re not getting your money’s worth.
	# engagement index
		# percent of active learners per day over time (is registered in current course, submitted an assignment and/or interacted with meterials in past month)
		# the average times users accesses the platform (number of days interactions occured in lieu of login data)
        # the average number of actions they perform each module (interactions with materials)
        # - consumption rate (also called usage rate)
		# - percentage of completed courses (in above query)
		# Xpercentage of learners who self-enroll in courses (not possible as marketing funnel not in dataset)
        
# percent of active learners per day over time (is registered in current course, interacted with meterials in past month)
# FIX
SELECT 
    inter.code_module,
    inter.code_presentation,
    COUNT(si.id_student) AS active_students
FROM 
    OULAD.interactions AS inter
JOIN 
    OULAD.student_info AS si ON inter.id_student = si.id_student
JOIN 
    OULAD.assessment_results AS ar ON si.id_student = ar.id_student
WHERE
    si.final_result NOT IN ('Withdrawn', 'Fail') 
    AND inter.date <= 30
GROUP BY 
    inter.code_module, inter.code_presentation;



# consumption rate (also called usage rate)
# % of assessments completed in 30 days from module start
SELECT code_module, 
	code_presentation, 
    ROUND((total_completed_assessments / NULLIF(total_assessments * total_students, 0)) * 100) AS completion_rate
FROM (
	SELECT
		a.code_module, 
		a.code_presentation,
		COALESCE(SUM(CASE WHEN ar.date_submitted <= 30 THEN 1 ELSE 0 END), 0) AS total_completed_assessments,
		COUNT(DISTINCT ar.id_assessment) AS total_assessments,
		COUNT(DISTINCT ar.id_student) AS total_students
	FROM 
		OULAD.assessments AS a
	LEFT JOIN 
		OULAD.assessment_results AS ar ON a.id_assessment = ar.id_assessment
	GROUP BY 
		a.code_module, 
		a.code_presentation
    ) AS subquery
ORDER BY code_module;

# explore average number of interactions per user, per module presentation
#FiX SELECT subquery.code_module, subquery.code_presentation, AVG(subquery.total_clicks)
FROM (
    SELECT student_registration.code_module, student_registration.code_presentation, student_registration.id_student, SUM(interactions.sum_click) AS total_clicks
    FROM OULAD.student_registration
    LEFT JOIN OULAD.interactions
    ON student_registration.code_module = interactions.code_module
        AND student_registration.code_presentation = interactions.code_presentation
        AND student_registration.id_student = interactions.id_student
    WHERE student_registration.date_registration IS NOT NULL
    GROUP BY student_registration.code_module, student_registration.code_presentation, student_registration.id_student
) AS subquery
GROUP BY subquery.code_module, subquery.code_presentation;

# explore average number times each student accesses the platform during a module presenation (number of days interactions occured in lieu of login data)
# Fix SELECT subquery.code_module, subquery.code_presentation, AVG(subquery.access_total)
FROM (
    SELECT student_registration.code_module, student_registration.code_presentation, student_registration.id_student, COUNT(interactions.date) AS access_total
    FROM OULAD.student_registration
    LEFT JOIN OULAD.interactions
    ON student_registration.code_module = interactions.code_module
        AND student_registration.code_presentation = interactions.code_presentation
        AND student_registration.id_student = interactions.id_student
    WHERE student_registration.date_registration IS NOT NULL
    GROUP BY student_registration.code_module, student_registration.code_presentation, student_registration.id_student
) AS subquery
GROUP BY subquery.code_module, subquery.code_presentation;


