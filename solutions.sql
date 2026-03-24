--Aula 04.B.ac Expressões JOIN e Views
-- Conexão: Azure

-- Questão 1: lista de instrutores com número de seções ministradas (outer join + sem subconsulta escalar)
SELECT
    i.ID,
    i.name,
    COUNT(t.course_id) AS num_sections
FROM instructor AS i
LEFT JOIN teaches AS t
    ON i.ID = t.ID
GROUP BY i.ID, i.name
ORDER BY i.ID;


-- Questão 2: mesma lista usando subconsulta escalar (sem outer join na consulta principal)
SELECT
    i.ID,
    i.name,
    (SELECT COUNT(*)
     FROM teaches AS t
     WHERE t.ID = i.ID) AS num_sections
FROM instructor AS i
ORDER BY i.ID;


-- Questão 3: seções primavera 2010 e nome de instrutor (seção sem instrutor aparece com "-")
SELECT
    s.course_id,
    s.sec_id,
    s.semester,
    s.year,
    s.building,
    s.room_number,
    COALESCE(i.name, '-') AS instructor_name
FROM section AS s
LEFT JOIN teaches AS t
    ON s.course_id = t.course_id
    AND s.sec_id = t.sec_id
    AND s.semester = t.semester
    AND s.year = t.year
LEFT JOIN instructor AS i
    ON t.ID = i.ID
WHERE s.semester = 'Spring'
  AND s.year = 2010
ORDER BY s.course_id, s.sec_id, instructor_name;


-- Questão 4: pontos totais por aluno (cria grade_points se faltar)
-- Utilizando grade_points(grade, points) para conversão de notas.
-- Fórmula utilizada: total_points = credits * grade_points
-- Os pontos totais representam a soma dos créditos do curso multiplicados
-- pelos pontos correspondentes à nota obtida pelo aluno.

IF OBJECT_ID('dbo.grade_points', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.grade_points (
        grade varchar(2) NOT NULL PRIMARY KEY,
        points decimal(3,2) NOT NULL
    );

    INSERT INTO dbo.grade_points (grade, points) VALUES
    ('A+', 4.00),
    ('A', 3.70),
    ('A-', 3.40),
    ('B+', 3.10),
    ('B', 2.80),
    ('B-', 2.50),
    ('C+', 2.20),
    ('C', 2.00),
    ('C-', 1.70),
    ('D', 1.00),
    ('F', 0.00);
END;

SELECT
    st.ID AS student_ID,
    st.name AS student_name,
    SUM(c.credits * gp.points) AS total_points
FROM takes AS tk
JOIN student AS st
    ON tk.ID = st.ID
JOIN course AS c
    ON tk.course_id = c.course_id
JOIN grade_points AS gp
    ON tk.grade = gp.grade
GROUP BY st.ID, st.name
ORDER BY st.ID;


-- Questão 5: view "coeficiente_rendimento" baseada na consulta da Questão 4
IF OBJECT_ID('dbo.coeficiente_rendimento', 'V') IS NOT NULL
    DROP VIEW dbo.coeficiente_rendimento;

CREATE VIEW dbo.coeficiente_rendimento AS
SELECT
    st.ID AS student_ID,
    st.name AS student_name,
    SUM(c.credits * gp.points) AS total_points
FROM takes AS tk
JOIN student AS st
    ON tk.ID = st.ID
JOIN course AS c
    ON tk.course_id = c.course_id
JOIN grade_points AS gp
    ON tk.grade = gp.grade
GROUP BY st.ID, st.name;

-- Testar a View

SELECT * FROM dbo.coeficiente_rendimento
ORDER BY student_ID;