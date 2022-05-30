Triggers

1. ----------------------

CREATE DATABASE Mitest01;
USE Mitest01;

CREATE TABLE alumnos (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
nombre VARCHAR(30) NOT NULL, 
apellido1 VARCHAR(30) NOT NULL, 
apellido2 VARCHAR(30), 
nota FLOAT);

DELIMITER $$
CREATE TRIGGER trigger_check_nota_before_insert
BEFORE INSERT
ON alumnos FOR EACH ROW
BEGIN
IF NEW.nota < 0 THEN
set NEW.nota = 0;
ELSEIF NEW.nota > 10 THEN
set NEW.nota = 10;
END IF;
END $$

INSERT INTO alumnos VALUES (1, 'Geovani', 'Bracamonte', 'Velásquez', 9);
INSERT INTO alumnos VALUES (2, 'Heinz', 'Villegas', 'Rodriguez', -5);
INSERT INTO alumnos VALUES (3, 'Carlota', 'Marriaga', 'Rodolfina', 14);
INSERT INTO alumnos VALUES (4, 'Mariana', 'Pajon', 'Diaz', 2);
INSERT INTO alumnos VALUES (5, 'Luis', 'Diaz', 'Mogollon', 8);
INSERT INTO alumnos VALUES (6, 'Luisa', 'Martinez', 'Guevara',11);
INSERT INTO alumnos VALUES (7, 'Karen', 'Policarpa', 'Lozano', -3);

SELECT * FROM alumnos;

DELIMITER $$
CREATE TRIGGER trigger_check_nota_before_update
BEFORE UPDATE
ON alumnos FOR EACH ROW
BEGIN
IF NEW.nota < 0 THEN
set NEW.nota = 0;
ELSEIF NEW.nota > 10 THEN
set NEW.nota = 10;
END IF;
END$$

UPDATE alumnos SET nota = -4 WHERE id = 1;
UPDATE alumnos SET nota = 17 WHERE id = 2;
UPDATE alumnos SET nota = 5 WHERE id = 3;

SELECT * FROM alumnos;

2. ----------------------------

CREATE DATABASE Mitest02;
USE Mitest02;

CREATE TABLE alumnos (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(30) NOT NULL,
apellido1 VARCHAR(30) NOT NULL,
apellido2 VARCHAR(30),
email VARCHAR(80)
);

DELIMITER $$
CREATE PROCEDURE crear_email(IN nombre VARCHAR(30),
IN apellido1 VARCHAR(30),
IN apellido2 VARCHAR(30),
IN dominio VARCHAR(40),
OUT email VARCHAR(100))
BEGIN
SET email = CONCAT(SUBSTR(nombre,1,1), SUBSTR(apellido1,1,3), SUBSTR(apellido2,1,3), '@', dominio);
SET email = LOWER(email);
END$$

DELIMITER $$
CREATE TRIGGER trigger_crear_email_before_insert
BEFORE INSERT
ON alumnos FOR EACH ROW
BEGIN
DECLARE email VARCHAR(100);
DECLARE dominio VARCHAR(40);
SET dominio = 'sonicmaster.co';
IF NEW.email IS NULL THEN
CALL crear_email(NEW.nombre,
NEW.apellido1,
NEW.apellido2,
dominio,
@email);
SET NEW.email = @email;
END IF;
END$$

INSERT INTO alumnos VALUES (1,'Mariano', 'Closs', 'Nisperuza', 'MarianoCN@gmail.com');
INSERT INTO alumnos VALUES (2,'Cristiano', 'Ronaldo', 'Santos', NULL);
INSERT INTO alumnos VALUES (3,'Juana', 'Vergara', 'Vergara', NULL);
INSERT INTO alumnos VALUES (4,'Ana', 'Bernarda', 'Manzanares', NULL);
INSERT INTO alumnos VALUES (5,'Maribel', 'Restrepo', 'Valencia', 'Maabel22@gmail.com');
INSERT INTO alumnos VALUES (6,'Jamilton', 'Benitez', 'Perez', NULL);
INSERT INTO alumnos VALUES (7,'Juan', 'Montoya', 'Yitzz', 'MontoyaY@gmail.com');

SELECT * FROM alumnos;

3. -----------------------------

CREATE TABLE log_cambios_email (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
id_alumno INT UNSIGNED,
fecha_hora TIMESTAMP,
old_email VARCHAR(128),
new_email VARCHAR(128),
FOREIGN KEY (id_alumno) REFERENCES alumnos(id));

DELIMITER $$
CREATE TRIGGER trigger_guardar_email_after_update2
AFTER UPDATE
ON alumnos FOR EACH ROW
BEGIN
IF OLD.email <> NEW.email THEN
INSERT INTO log_cambios_email (id_alumno, fecha_hora, old_email, new_email)
VALUES (OLD.id, NOW(), OLD.email, NEW.email);
END IF;
END$$

UPDATE alumnos SET email = 'MariBEL533@hotmail.com' WHERE id = 5;
SELECT * FROM alumnos;
SELECT * FROM log_cambios_email;

4.------------------------------

CREATE TABLE log_alumnos_eliminados (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
id_alumno INT UNSIGNED,
fecha_hora TIMESTAMP,
nombre VARCHAR(30) NOT NULL,
apellido1 VARCHAR(30) NOT NULL,
apellido2 VARCHAR(30),
email VARCHAR(100));

DELIMITER $$
CREATE TRIGGER trigger_guardar_alumnos_eliminados
AFTER DELETE
ON alumnos FOR EACH ROW
BEGIN
INSERT INTO log_alumnos_eliminados VALUES (NULL, OLD.id, NOW(), OLD.nombre, OLD.apellido1, OLD.apellido2, OLD.email);
END$$

DELETE FROM alumnos WHERE id = 6;
DELETE FROM alumnos WHERE id = 3;
SELECT * FROM alumnos;
SELECT * FROM log_alumnos_eliminados;



