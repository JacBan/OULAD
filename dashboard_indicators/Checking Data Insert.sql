SELECT `assessment_results`.`id_assessment`,
    `assessment_results`.`id_student`,
    `assessment_results`.`date_submitted`,
    `assessment_results`.`is_banked`,
    `assessment_results`.`score`
FROM `OULAD`.`assessment_results`
LIMIT 5;

SELECT COUNT(*)
FROM `OULAD`.`assessment_results`;

# in assessment_results table no data types have been changed
# assessment_results has the correct number of records

SELECT `assessments`.`code_module`,
    `assessments`.`code_presentation`,
    `assessments`.`id_assessment`,
    `assessments`.`assessment_type`,
    `assessments`.`date`,
    `assessments`.`weight`
FROM `OULAD`.`assessments`
LIMIT 5;

SELECT COUNT(*)
FROM `OULAD`.`assessments`;

# in assessments table - id_assessment was forced to bigint, date and weight are forced to double
# assessments has the correct number of records

SELECT `courses`.`code_module`,
    `courses`.`code_presentation`,
    `courses`.`module_presentation_length`
FROM `OULAD`.`courses`
LIMIT 5;

SELECT COUNT(*)
FROM `OULAD`.`courses`;

# in courses table - module_presentation_length was forced to bigint
# courses has the correct number of records

SELECT `interactions`.`code_module`,
    `interactions`.`code_presentation`,
    `interactions`.`id_student`,
    `interactions`.`id_site`,
    `interactions`.`date`,
    `interactions`.`sum_click`
FROM `OULAD`.`interactions`
LIMIT 5;

SELECT COUNT(*)
FROM `OULAD`.`interactions`;

# in interactions table - id_student, id_site, and sum_click were forced to bigint
# interactions has the correct number of records

SELECT `student_info`.`code_module`,
    `student_info`.`code_presentation`,
    `student_info`.`id_student`,
    `student_info`.`gender`,
    `student_info`.`region`,
    `student_info`.`highest_education`,
    `student_info`.`imd_band`,
    `student_info`.`age_band`,
    `student_info`.`num_of_prev_attempts`,
    `student_info`.`studied_credits`,
    `student_info`.`disability`,
    `student_info`.`final_result`
FROM `OULAD`.`student_info`
LIMIt 5;

SELECT COUNT(*)
FROM `OULAD`.`student_info`;

# in student_info table - id_student, num_of_prev_attempts, and studied_credits were forced to bigint
# student_info has the correct number of records

SELECT `student_registration`.`code_module`,
    `student_registration`.`code_presentation`,
    `student_registration`.`id_student`,
    `student_registration`.`date_registration`,
    `student_registration`.`date_unregistration`
FROM `OULAD`.`student_registration`
LIMIT 5;

SELECT COUNT(*)
FROM `OULAD`.`student_registration`;

# in student_registration table - id_student was forced to bigint, date_registration and date_unregistration were forced to double
# student_registration has the correct number of records

SELECT `vle_materials`.`id_site`,
    `vle_materials`.`code_module`,
    `vle_materials`.`code_presentation`,
    `vle_materials`.`activity_type`,
    `vle_materials`.`week_from`,
    `vle_materials`.`week_to`
FROM `OULAD`.`vle_materials`
LIMIT 5;

SELECT COUNT(*)
FROM `OULAD`.`vle_materials`;

# in vle_materials table - id_site was forced to bigint, week_from and week_to were forced to double
# vle_materials has the correct number of records

