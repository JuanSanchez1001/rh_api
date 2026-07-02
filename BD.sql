--
-- PostgreSQL database dump
--

\restrict tZB4J7eGYIgRy00FXK09qXL4Vd5FfEUtUN2Q1yv5ly4iIW6v6YNJf8VcfGuS4w0

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.1

-- Started on 2026-07-02 14:28:02

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 7 (class 2615 OID 17323)
-- Name: rh; Type: SCHEMA; Schema: -; Owner: dbo
--

CREATE SCHEMA rh;


ALTER SCHEMA rh OWNER TO dbo;

--
-- TOC entry 8 (class 2615 OID 17324)
-- Name: tickets; Type: SCHEMA; Schema: -; Owner: dbo
--

CREATE SCHEMA tickets;


ALTER SCHEMA tickets OWNER TO dbo;

--
-- TOC entry 319 (class 1255 OID 17593)
-- Name: fn_getmaildata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getmaildata(v_nomina integer) RETURNS TABLE(nombre integer, correo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	CONCAT(nombre, ' ', ape_paterno, ' ', ape_materno),
	correo
FROM rh.users
WHERE nomina = v_nomina;
END;
$$;


ALTER FUNCTION public.fn_getmaildata(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 17389)
-- Name: fn_getallusers(); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getallusers() RETURNS TABLE(nomina integer, nombre text, dept character varying, rol character varying, super text, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
WITH supervisores AS (
	SELECT
	distinct
		supervior_idf as superid
		--concat(s.nombre, ' ', s.ape_paterno) as nombre
		FROM rh.users s
)
	SELECT
		u.nomina,
		concat(u.nombre, ' ', u.ape_paterno),
		d.departamento,
		p.descripcion,
		concat(u1.nombre, ' ', u1.ape_paterno),
		u.correo
	FROM rh.users u
	LEFT JOIN rh.departaments d ON(u.department_idf = d.id_departamento)
	LEFT JOIN rh.puestos p ON(u.puesto_idf = p.id)
	LEFT JOIN supervisores s ON(s.superid = u.supervior_idf)
	LEFT JOIN rh.users u1 ON(s.superid = u1.nomina)
	;
END;
$$;


ALTER FUNCTION rh.fn_getallusers() OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 17390)
-- Name: fn_getausenciabyid(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getausenciabyid(v_incidencia integer) RETURNS TABLE(id integer, nombre text, motivo character varying, goceflag integer, vacacionesflag integer, telefono character varying, diasqty integer, fecha_ini date, decha_fin date, autorizaflag integer, voboflag integer, descripcion text, observaciones text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		i.id,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		m.descripcion as motivo,
		i.goceidf,
		i.vacacionesflag,
		i.telefono,
		i.dias_qty,
		i.fecha_ini,
		i.fecha_fin,
		i.autoriza_flag,
		i.vobo_flag,
		i.descripcion,
		i.observaciones
	FROM rh.incidencia_data i
	JOIN rh.motivos m ON(i.motivoidf = m.id)
	JOIN rh.users u ON(i.useridf = u.nomina)
	WHERE i.id = v_incidencia;
END;
$$;


ALTER FUNCTION rh.fn_getausenciabyid(v_incidencia integer) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 17391)
-- Name: fn_getdepartamentos(); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getdepartamentos() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT 
		id_departamento,
		departamento
	FROM rh.departaments
	WHERE visible IS true;
END;
$$;


ALTER FUNCTION rh.fn_getdepartamentos() OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 17392)
-- Name: fn_getincidenciabyid(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getincidenciabyid(v_id integer) RETURNS TABLE(id integer, nombre text, motivo character varying, goceflag integer, tipoauto text, placas character varying, lugar character varying, telefono character varying, descripcion text, observaciones text, regresaflag integer, acompanantesqty integer, hora_salida character varying, hora_regreo character varying, diasqty integer, fecha_ini text, fecha_fin text, autorizaflga integer, voboflag integer, vacacionesflag integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		d.id,
		concat(u.nombre, ' ', u.ape_paterno, ' ', ape_materno) as nombre,
		m.descripcion as motivo,
		COALESCE(d.goceidf,0),
		CASE d.tipoautoidf
			WHEN 1 THEN 'NA'
			WHEN 2 THEN 'Propio'
			WHEN 3 THEN 'Empresa'
			ELSE ''
		END AS tipoauto,
		d.placas,
		d.lugar,
		d.telefono,
		d.descripcion,
		d.observaciones,
		d.regresa_flag,
		d.acompanantes_qty,
		d.hora_salida,
		d.hora_regreso,
		d.dias_qty,
		to_char(d.fecha_ini, 'yyyy-mm-dd') as fecha_ini,
		to_char(d.fecha_fin, 'yyyy-mm-dd') as fecha_fin,
		COALESCE(d.autoriza_flag,0) as autoriza_flag,
		COALESCE(d.vobo_flag, 0) as voboflag,
		COALESCE(d.vacacionesflag,0) as vacacionesflag
	FROM rh.incidencia_data d
	JOIN rh.users u ON(d.useridf = u.nomina)
	JOIN rh.motivos m ON(d.motivoidf = m.id)
	WHERE d.id = v_id;
END;
$$;


ALTER FUNCTION rh.fn_getincidenciabyid(v_id integer) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 17393)
-- Name: fn_getincidencias(); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getincidencias() RETURNS TABLE(v_id integer, v_nomina integer, v_nombre text, v_fecha timestamp without time zone, v_motivo character varying, v_tipo text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		d.fecha_creacion,
		m.descripcion as motivo,
		CASE d.tipo
			WHEN 1 THEN 'SALIDA'
			WHEN 2 THEN 'AUSENCIA'
			ELSE ''
		END AS tipo_incidenia
	FROM rh.incidencia_data d
	JOIN rh.users u ON (d.useridf = u.nomina)
	JOIN rh.motivos m ON (d.motivoidf = m.id)
	WHERE (d.autoriza_flag is null 
	or d.vobo_flag is null)
	--and d.tipo = 2
	order by d.fecha_creacion desc
	;
END;
$$;


ALTER FUNCTION rh.fn_getincidencias() OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 17394)
-- Name: fn_getmotivos(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getmotivos(v_tipoincidencia integer) RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT
	m.id,
	m.descripcion
	FROM rh.motivos m
	WHERE m.tipoincidenciaidf = v_tipoincidencia and m.visible = 1;
END;
$$;


ALTER FUNCTION rh.fn_getmotivos(v_tipoincidencia integer) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 17395)
-- Name: fn_getpuestos(); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getpuestos() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT 
		p.id,
		p.descripcion
	FROM rh.puestos p
	WHERE visible = 1;
END;
$$;


ALTER FUNCTION rh.fn_getpuestos() OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 17396)
-- Name: fn_getroles(); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getroles() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT 
		r.rolid,
		r.description
	FROM rh.roles r
	WHERE visible = 1
	ORDER BY rolid DESC
	;
END;
$$;


ALTER FUNCTION rh.fn_getroles() OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 17397)
-- Name: fn_getsalidabyid(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getsalidabyid(v_incidencia integer) RETURNS TABLE(id integer, nombre text, motivo character varying, goceflag integer, tipoauto text, placas character varying, lugar character varying, telefono character varying, autorizaflgar integer, descripcion text, observaciones text, regresaflag integer, acompanantesqty integer, hora_salida character varying, hora_regreo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT 
		i.id,
		concat(u.nombre, ' ', u.ape_paterno, ' ', ape_materno),
		m.descripcion as motivo,
		i.goceidf,
		--i.vacacionesflag,
		CASE i.tipoautoidf
			WHEN 1 THEN 'NA'
			WHEN 2 THEN 'Propio'
			WHEN 3 THEN 'Empresa'
			ELSE ''
		END AS tipoauto,
		i.placas,
		i.lugar,
		i.telefono,
		i.autoriza_flag,
		i.descripcion,
		i.observaciones,
		i.regresa_flag,
		i.acompanantes_qty,
		i.hora_salida,
		i.hora_regreso
		
	FROM rh.incidencia_data i
	JOIN rh.users u ON (i.useridf = u.nomina)
	JOIN rh.motivos m ON(i.motivoidf = m.id)
	WHERE i.id = V_INCIDENCIA;
END;
$$;


ALTER FUNCTION rh.fn_getsalidabyid(v_incidencia integer) OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 17398)
-- Name: fn_gettablaausencias(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_gettablaausencias(v_userid integer) RETURNS TABLE(v_id integer, v_nomina integer, v_nombre text, v_fecha text, v_motivo character varying, v_estatus text)
    LANGUAGE plpgsql
    AS $$
DECLARE isAdmin integer := ( select rol_idf from rh.users where nomina = v_userid);
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		to_char(d.fecha_creacion, 'dd/mm/yyyy'),
		m.descripcion as motivo,
		CASE
			WHEN d.autoriza_flag = 0 AND vobo_flag = 0 THEN 'Pendiente voBo y autorizacion'
			WHEN d.autoriza_flag = 0 AND vobo_flag <> 0 THEN 'Pendiente aut'
			WHEN d.vobo_flag = 0 AND d.autoriza_flag <> 0 THEN 'Pendiente VoBo'
		ELSE '' END estatus
		
	FROM rh.incidencia_data d
	LEFT JOIN rh.users u ON (d.useridf = u.nomina)
	LEFT JOIN rh.motivos m ON (d.motivoidf = m.id)
	WHERE (d.autoriza_flag = 0
	or d.vobo_flag = 0)
	and d.tipo = 2
	and (u.supervior_idf = 
		CASE isAdmin
			WHEN 1 THEN u.supervior_idf
			ELSE 0
			END
		)
	order by d.fecha_creacion desc
	;
END;
$$;


ALTER FUNCTION rh.fn_gettablaausencias(v_userid integer) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 17399)
-- Name: fn_gettablasalidas(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_gettablasalidas(v_userid integer) RETURNS TABLE(v_id integer, v_nomina integer, v_nombre text, v_fecha text, v_motivo character varying, v_estatus text)
    LANGUAGE plpgsql
    AS $$
DECLARE isAdmin integer := ( select rol_idf from rh.users where nomina = v_userid);
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		to_char(d.fecha_creacion, 'dd/mm/yyyy'),
		m.descripcion as motivo,
		CASE
			WHEN d.autoriza_flag = 0 THEN 'Pendiente'
			WHEN d.autoriza_flag = 1 THEN 'Autorizado'
			WHEN d.autoriza_flag = 2 THEN 'Rechazado'
		ELSE '' END AS estatus
	FROM rh.incidencia_data d
	JOIN rh.users u ON (d.useridf = u.nomina)
	JOIN rh.motivos m ON (d.motivoidf = m.id)
	WHERE (d.autoriza_flag = 0)
	and d.tipo = 1
	and (u.supervior_idf = 
		CASE isAdmin
			WHEN 1 THEN u.supervior_idf
			ELSE v_userid
			END
		)
	order by d.fecha_creacion desc
	;
END;
$$;


ALTER FUNCTION rh.fn_gettablasalidas(v_userid integer) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 17539)
-- Name: fn_gettablavigilancia(); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_gettablavigilancia() RETURNS TABLE(v_id integer, v_nomina integer, v_nombre text, v_placas character varying, v_hora_salida character varying, v_acompanantesqty integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
v_today timestamp := to_char(current_timestamp, 'YYYY-MM-DD');
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno) AS nombre,
		d.placas,
		d.hora_salida,
		d.acompanantes_qty
	FROM rh.incidencia_data d
	LEFT JOIN rh.users u ON(d.useridf = u.nomina)

	WHERE d.tipo = 1
	AND to_char(d.fecha_creacion, 'YYYY-MM-DD')::date = v_today
	AND d.autoriza_flag = 1;
END;
$$;


ALTER FUNCTION rh.fn_gettablavigilancia() OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 17400)
-- Name: fn_getuserbyid(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getuserbyid(v_nomina integer) RETURNS TABLE(nomina integer, nombre character varying, ape_paterno character varying, ape_materno character varying, genero character varying, correo character varying, edad numeric, username character varying, superidf integer, dept_id integer, puesto_id integer, rol_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		u.nomina,
		u.nombre,
		u.ape_paterno,
		u.ape_materno,
		u.genero,
		u.correo,
		u.edad,
		u.username,
		supervior_idf,
		u.department_idf,
		u.puesto_idf,
		u.rol_idf
	FROM rh.users u
	WHERE u.nomina = v_nomina;
END;
$$;


ALTER FUNCTION rh.fn_getuserbyid(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 17619)
-- Name: fn_getusermenu(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getusermenu(v_nomina integer) RETURNS TABLE(id integer, title character varying, icon character varying, style text, url text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_isAdmin integer := (
						select u.rol_idf 
						from rh.users u 
						--join rh.departaments d on(u.department_idf=d.id_departamento)
						where u.nomina = v_nomina);
	isLogged integer := CASE v_nomina
							WHEN 0 THEN 0
							ELSE 1
							END;
BEGIN
	IF isLogged = 0 THEN
	RETURN QUERY
		SELECT d.id_menu, d.descripcion, d.icon, d.style,d.url
		FROM rh.menu_data d where d.sesionflag = 0
		ORDER BY d.orden
		;
	ELSE
	RETURN QUERY
		SELECT d.id_menu, d.descripcion, d.icon, d.style,d.url
		FROM rh.menu_data d where d.sesionflag <> 0
		AND d.rolidf = CASE 
							WHEN d.rolidf = 0 THEN rolidf
							WHEN v_isAdmin = 1 THEN rolidf
							ELSE 0
						END
		ORDER BY d.orden				
		;
	END IF;
END;
$$;


ALTER FUNCTION rh.fn_getusermenu(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 17402)
-- Name: fn_login(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_login(v_nomina integer) RETURNS TABLE(nomina integer, hash text, username character varying, nombre text, departamento character varying, rol character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
--Validaciones del login
RETURN QUERY
select  
	u.nomina,
	u.hash_pass,
	u.username,
	concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno) AS nombre,
	d.departamento,
	p.descripcion puesto
from RH.users u
LEFT JOIN rh.departaments d ON(u.department_idf=id_departamento)
LEFT JOIN rh.puestos p ON(u.puesto_idf = p.id)
where u.nomina = v_nomina;
			--v_estatus := 1;
END;
$$;


ALTER FUNCTION rh.fn_login(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 17470)
-- Name: fn_reporte_ausencias(date, date, integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_reporte_ausencias(fecha1 date, fecha2 date, estatus integer) RETURNS TABLE(v_id integer, v_useridf integer, v_motivo character varying, v_goce text, v_uso_vacacion text, v_tel character varying, v_diasqty integer, v_fecha_ini text, v_fecha_fin text, v_autoriza text, v_vobo text, v_descripcion text, v_observaciones text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		m.descripcion as motivo,
		CASE d.goceidf
			WHEN 1 THEN 'Con Goce'
			WHEN 2 THEN 'Sin Goce'
		ELSE '' END AS goce,
		CASE d.vacacionesflag
			WHEN 1 THEN 'Usa vacaciones'
			WHEN 0 THEN 'No usa vacaciones'
			ELSE '' END AS usaVacaciones,
		d.telefono,
		d.dias_qty,
		TO_CHAR(d.fecha_ini, 'YYYY-MM-DD'),
		TO_CHAR(d.fecha_fin, 'YYYY-MM-DD'),
		CASE d.autoriza_flag
			WHEN 1 THEN 'Autoriza'
			WHEN 2 THEN 'No Autoriza'
			WHEN 0 THEN 'Pendiente'
			ELSE '' END AS autoriza,
		CASE d.vobo_flag
			WHEN 1 THEN 'VoBo'
			WHEN 2 THEN 'No VoBo'
			WHEN 0 THEN ''
			ELSE '' END AS vobo,
		d.descripcion,
		d.observaciones
		
	FROM rh.incidencia_data d
	LEFT JOIN rh.motivos m ON (d.motivoidf = m.id)
	--LEFT JOIN 
	WHERE d.fecha_creacion::date BETWEEN fecha1 AND fecha2
		AND d.tipo = 2--tipo_incidencia
		AND (d.autoriza_flag = estatus OR estatus = 3)
		;
END;
$$;


ALTER FUNCTION rh.fn_reporte_ausencias(fecha1 date, fecha2 date, estatus integer) OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 17469)
-- Name: fn_reporte_salidas(date, date, integer, integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_reporte_salidas(fecha1 date, fecha2 date, tipo_incidencia integer, estatus integer) RETURNS TABLE(v_id integer, v_nomina integer, v_tipoauto text, v_placas character varying, v_motivo character varying, v_tel character varying, v_regresa text, v_autoriza text, v_h_salida character varying, v_h_regreso character varying, v_lugar character varying, v_descripcion text, v_obs text, v_acompqty integer, v_a1 integer, v_a2 integer, v_a3 integer, v_a4 integer, v_a5 integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
WITH acompananates_table AS(
	SELECT * FROM CROSSTAB(
		'
			SELECT incidencia_df,
			acomp,
			nomina
			FROM rh.acompanantes a
		'
	) AS pivot (
		id integer,
		acomp1 integer,
		acomp2 integer,
		acomp3 integer,
		acomp4 integer,
		acomp5 integer
	)
)
SELECT
	d.id,
	d.useridf as solicitante,
	CASE tipoautoidf
		WHEN 1 THEN 'NA'
		WHEN 2 THEN 'Propio'
		WHEN 3 THEN 'Empresa'
		ELSE ''
	END tipoauto,
	d.placas,
	m.descripcion AS motivo,
	d.telefono,
	CASE d.regresa_flag
		WHEN 1 THEN 'Regresa'
		WHEN 0 THEN 'No regresa'
	END AS regresa,
	CASE d.autoriza_flag
		WHEN 1 THEN 'Autoriza'
		WHEN 2 THEN 'No Autoriza'
		WHEN 0 THEN 'Pendiente'
	ELSE '' END AS autoriza,
	d.hora_salida,
	d.hora_regreso,
	d.lugar,
	d.descripcion,
	d.observaciones,
	d.acompanantes_qty,
	acomps.acomp1,
	acomps.acomp2,
	acomps.acomp3,
	acomps.acomp4,
	acomps.acomp5
	
FROM rh.incidencia_data d
LEFT JOIN rh.users u ON (d.useridf = u.nomina)
LEFT JOIN rh.motivos m ON (d.motivoidf = m.id)
LEFT JOIN acompananates_table acomps ON (d.id = acomps.id)
WHERE d.fecha_creacion::date BETWEEN fecha1 AND fecha2
AND d.tipo = tipo_incidencia
AND (d.autoriza_flag = estatus OR estatus = 3)
;
END;
$$;


ALTER FUNCTION rh.fn_reporte_salidas(fecha1 date, fecha2 date, tipo_incidencia integer, estatus integer) OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 17404)
-- Name: searchuser(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.searchuser(v_nomina integer) RETURNS TABLE(nomina integer, nombre text, departamento character varying, rol character varying, supervisor text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
WITH table_supervisor AS(
	SELECT
		distinct
		supervior_idf as id
	FROM rh.users
)
	SELECT
		u.nomina,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno) as nombre,
		d.departamento as departamento,
		p.descripcion as rol,
		concat(s.nombre, ' ', s.ape_paterno) as super
	FROM rh.users u
	LEFT JOIN rh.departaments d ON(u.department_idf = d.id_departamento)
	LEFT JOIN rh.puestos p ON(u.puesto_idf = p.id)
	LEFT JOIN table_supervisor ts ON(ts.id = u.supervior_idf) --join para jefe directo
	LEFT JOIN rh.users s ON(ts.id = s.nomina)
	WHERE u.nomina = v_nomina;
END;
$$;


ALTER FUNCTION rh.searchuser(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 17443)
-- Name: spd_delete_user(integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spd_delete_user(IN v_nomina integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM rh.users WHERE nomina = v_nomina;
END;
$$;


ALTER PROCEDURE rh.spd_delete_user(IN v_nomina integer) OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 17405)
-- Name: spd_deleteincidenciabyid(integer, text, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spd_deleteincidenciabyid(IN v_id integer, IN v_comment text, IN v_nomina integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD/MM/YYYY HH24:MI:SS');
BEGIN
	DELETE FROM rh.incidencia_data where id = v_id;

	INSERT INTO rh.incidencia_log (incidenciaidf, fecha, user_modify, comment)
	values (v_id, today, v_nomina, v_comment);
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spd_deleteincidenciabyid(IN v_id integer, IN v_comment text, IN v_nomina integer) OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 17406)
-- Name: spd_deleteuser(integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spd_deleteuser(IN v_nomina integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM rh.users
	WHERE nomina = v_nomina;
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spd_deleteuser(IN v_nomina integer) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 17437)
-- Name: spi_create_user(integer, character varying, character varying, character varying, character varying, character varying, integer, character varying, integer, integer, integer, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spi_create_user(IN v_nomina integer, IN v_nombre character varying, IN v_appaterno character varying, IN v_apmaterno character varying, IN v_genero character varying, IN v_mail character varying, IN v_edad integer, IN v_username character varying, IN v_super integer, IN v_dept integer, IN v_puesto integer, IN v_rol integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO rh.users(nomina, nombre, ape_paterno, ape_materno, genero, correo, edad, username, supervior_idf, department_idf, puesto_idf, rol_idf, reset)
	VALUES (v_nomina, v_nombre, v_apPaterno, v_apMaterno, v_genero, v_mail, v_edad, v_username, v_super, v_dept, v_puesto, v_rol, 1);
COMMIT;
END;
$$;


ALTER PROCEDURE rh.spi_create_user(IN v_nomina integer, IN v_nombre character varying, IN v_appaterno character varying, IN v_apmaterno character varying, IN v_genero character varying, IN v_mail character varying, IN v_edad integer, IN v_username character varying, IN v_super integer, IN v_dept integer, IN v_puesto integer, IN v_rol integer) OWNER TO postgres;

--
-- TOC entry 303 (class 1255 OID 17407)
-- Name: spi_solicitud_ausencia(integer, integer, integer, character varying, integer, date, date, text); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spi_solicitud_ausencia(IN v_nomina integer, IN v_motivo integer, IN v_vacacionesflag integer, IN v_telefono character varying, IN v_diasqty integer, IN v_fechaini date, IN v_fechafin date, IN v_descripcion text)
    LANGUAGE plpgsql
    AS $$
DECLARE 
today timestamp := to_char(current_timestamp, 'DD/MM/YYYY HH24:MI:SS');
v_incidencia integer;
BEGIN
	INSERT INTO rh.incidencia_data(useridf, motivoidf, vacacionesflag, fecha_creacion,
	telefono, dias_qty, fecha_ini, fecha_fin, descripcion, tipo, autoriza_flag, vobo_flag)
	VALUES (v_nomina, v_motivo, v_vacacionesFlag, today, v_telefono, v_diasQTY, v_fechaini, v_fechafin, v_descripcion, 2,0,0)
	RETURNING id INTO v_incidencia;
	
	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify, comment)
	VALUES (v_incidencia, today, v_nomina, 'NUEVO');
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spi_solicitud_ausencia(IN v_nomina integer, IN v_motivo integer, IN v_vacacionesflag integer, IN v_telefono character varying, IN v_diasqty integer, IN v_fechaini date, IN v_fechafin date, IN v_descripcion text) OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 17408)
-- Name: spi_solicitud_salida(integer, integer, character varying, integer, integer, character varying, integer, character varying, character varying, text, text, integer, integer, integer, integer, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spi_solicitud_salida(IN v_nomina integer, IN v_auto integer, IN v_placas character varying, IN v_motivo integer, IN acompananatesqty integer, IN v_tel character varying, IN regresaflag integer, IN v_salida character varying, IN v_regreso character varying, IN v_lugar text, IN v_descripcion text, IN v_acompanante1 integer DEFAULT 0, IN v_acompanante2 integer DEFAULT 0, IN v_acompanante3 integer DEFAULT 0, IN v_acompanante4 integer DEFAULT 0, IN v_acompanante5 integer DEFAULT 0)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD-MM-YYYY HH24:MI:SS');
v_incidencia integer;
array_acompanantes integer[] := ARRAY[v_acompanante1,v_acompanante2,v_acompanante3,v_acompanante4,v_acompanante5];
acompanante integer;
acompanante_index integer := 0;

BEGIN

	INSERT INTO rh.incidencia_data(useridf, motivoidf, tipoautoidf, placas, lugar, telefono, hora_salida,
	hora_regreso, descripcion, regresa_flag, acompanantes_qty, fecha_creacion, tipo, autoriza_flag)
	VALUES (v_nomina, v_motivo, v_auto, v_placas, v_lugar, v_tel, v_salida, v_regreso, v_descripcion, 
	regresaflag, acompananatesqty, today, 1, 0)
	--set variable
	RETURNING id INTO v_incidencia;
	
	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify, comment)
	VALUES(v_incidencia, today, v_nomina, 'NUEVO');

		FOREACH acompanante IN ARRAY array_acompanantes LOOP
			IF acompanante > 0 THEN
			acompanante_index := acompanante_index + 1;--Se guarda el numero de acompañante
				INSERT INTO rh.acompanantes(incidencia_df, nomina, acomp) VALUES (v_incidencia, acompanante, acompanante_index);
			END IF;
		END LOOP;
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spi_solicitud_salida(IN v_nomina integer, IN v_auto integer, IN v_placas character varying, IN v_motivo integer, IN acompananatesqty integer, IN v_tel character varying, IN regresaflag integer, IN v_salida character varying, IN v_regreso character varying, IN v_lugar text, IN v_descripcion text, IN v_acompanante1 integer, IN v_acompanante2 integer, IN v_acompanante3 integer, IN v_acompanante4 integer, IN v_acompanante5 integer) OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 17472)
-- Name: sps_getmaildata(integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.sps_getmaildata(IN v_nomina integer, OUT v_mails text)
    LANGUAGE plpgsql
    AS $$
BEGIN
WITH table_info AS(
	SELECT
		u1.supervior_idf as idsuper
		--concat(nombre, ' ', ape_paterno, ' ', ape_materno)
	FROM rh.users u1
	WHERE nomina = v_nomina
)

	SELECT
		INTO v_mails
		STRING_AGG(u.correo, ',')
	FROM rh.users u
	JOIN table_info s ON(u.nomina = s.idsuper OR u.rol_idf = 1);
END;
$$;


ALTER PROCEDURE rh.sps_getmaildata(IN v_nomina integer, OUT v_mails text) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 17541)
-- Name: sps_getnameuser(integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.sps_getnameuser(IN v_nomina integer, OUT nombre text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	SELECT
		into nombre
		CONCAT(u.nombre, ' ', u.ape_paterno)
	FROM rh.users
	WHERE u.nomina = v_nomina;
END;
$$;


ALTER PROCEDURE rh.sps_getnameuser(IN v_nomina integer, OUT nombre text) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 17409)
-- Name: sps_login(integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.sps_login(IN v_nomina integer, OUT v_estatus integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_exist integer;
	v_reset integer;
BEGIN
	select count(*) into v_exist from rh.users where nomina = v_nomina;
	select reset into v_reset
	from rh.users
	where nomina = v_nomina;
	IF v_exist = 1
	THEN
		IF v_reset = 1
			THEN v_estatus := 2; --reset pass
		ELSE
			v_estatus := 1; -- existe para hacer el login
		END IF;
	ElSEIF v_exist = 0
		THEN v_estatus := 0; -- No existe
	END IF;
END;
$$;


ALTER PROCEDURE rh.sps_login(IN v_nomina integer, OUT v_estatus integer) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 17434)
-- Name: spu_change_password(integer, text); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spu_change_password(IN v_nomina integer, IN v_hash text, OUT v_message integer)
    LANGUAGE plpgsql
    AS $$
DECLARE v_reset integer := (select reset from rh.users where nomina = v_nomina);
BEGIN
	IF v_reset = 1 THEN
		update rh.users set 
		hash_pass =v_hash,
		reset = 0
		where nomina = v_nomina;
		v_message := 1;
	ELSE 
		v_message := 0;
	END IF;
END;
$$;


ALTER PROCEDURE rh.spu_change_password(IN v_nomina integer, IN v_hash text, OUT v_message integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 17411)
-- Name: spu_editeuser(integer, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spu_editeuser(IN v_nomina integer, IN v_nombre character varying, IN v_apepaterno character varying, IN v_apematerno character varying, IN v_genero character varying, IN v_correo character varying, IN v_edad integer, IN v_jefedirecto integer, IN v_rolidf integer, IN v_departament integer, IN v_username character varying, IN v_cargo integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE rh.users SET
		correo = v_correo,
		edad = v_edad,
		supervisor_idf = v_jefeDirecto,
		department_idf = v_departament,
		username = v_username,
		puesto_idf = v_coargo
	WHERE nomina = v_nomina;
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spu_editeuser(IN v_nomina integer, IN v_nombre character varying, IN v_apepaterno character varying, IN v_apematerno character varying, IN v_genero character varying, IN v_correo character varying, IN v_edad integer, IN v_jefedirecto integer, IN v_rolidf integer, IN v_departament integer, IN v_username character varying, IN v_cargo integer) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 17442)
-- Name: spu_enable_reset_pass(integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spu_enable_reset_pass(IN v_nomina integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE rh.users SET
	reset = 1
	WHERE nomina = v_nomina;
END;
$$;


ALTER PROCEDURE rh.spu_enable_reset_pass(IN v_nomina integer) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 17412)
-- Name: spu_update_ausencia(integer, integer, integer, integer, integer, integer, date, date, integer, text); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spu_update_ausencia(IN v_id integer, IN v_usermodify integer, IN v_autorizaflag integer, IN v_voboflag integer, IN v_goceflag integer, IN v_vacacionesflag integer, IN v_fechaini date, IN v_fechafin date, IN v_diasqty integer, IN v_observaciones text)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD/MM/YYYY HH24:MI:SS');
BEGIN
	UPDATE 
	rh.incidencia_data
	SET
	goceidf = v_goceflag,
	autoriza_flag = v_autorizaflag,
	vobo_flag = v_voboflag,
	vacacionesflag = v_vacacionesflag,
	fecha_ini = v_fechaIni,
	fecha_fin = v_fechaFin,
	dias_qty = v_diasQTY,
	observaciones = v_observaciones
	WHERE id = v_id;

	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify,comment)
	VALUES (v_id, today, v_userModify, v_observaciones);

	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spu_update_ausencia(IN v_id integer, IN v_usermodify integer, IN v_autorizaflag integer, IN v_voboflag integer, IN v_goceflag integer, IN v_vacacionesflag integer, IN v_fechaini date, IN v_fechafin date, IN v_diasqty integer, IN v_observaciones text) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 17414)
-- Name: spu_update_salida(integer, integer, integer, integer, integer, character varying, character varying, character varying, integer, text); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spu_update_salida(IN v_id integer, IN v_usermodify integer, IN v_autorizaflag integer, IN v_voboflag integer, IN v_goceflag integer, IN v_placas character varying, IN v_horasalida character varying, IN v_horaregreso character varying, IN v_regresaflag integer, IN v_observaciones text)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD/MM/YYYY HH24:MI:SS');
BEGIN
	UPDATE 
	rh.incidencia_data
	SET
	goceidf = v_goceflag,
	autoriza_flag = v_autorizaflag,
	vobo_flag = v_voboflag,
	regresa_flag = v_regresaFlag,
	placas = v_placas,
	hora_salida = v_horaSalida,
	hora_regreso = v_horaRegreso,
	observaciones = v_observaciones
	WHERE id = v_id;

	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify,comment)
	VALUES (v_id, today, v_userModify, v_observaciones);

	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spu_update_salida(IN v_id integer, IN v_usermodify integer, IN v_autorizaflag integer, IN v_voboflag integer, IN v_goceflag integer, IN v_placas character varying, IN v_horasalida character varying, IN v_horaregreso character varying, IN v_regresaflag integer, IN v_observaciones text) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 17444)
-- Name: spu_update_user(integer, character varying, character varying, character varying, character varying, character varying, integer, character varying, integer, integer, integer, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spu_update_user(IN v_nomina integer, IN v_nombre character varying, IN v_appaterno character varying, IN v_apmaterno character varying, IN v_genero character varying, IN v_mail character varying, IN v_edad integer, IN v_username character varying, IN v_super integer, IN v_dept integer, IN v_puesto integer, IN v_rol integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE rh.users SET
	--nomina = v_nomina,
	nombre = v_nombre,
	ape_paterno = v_appaterno,
	ape_materno = v_apmaterno,
	genero = v_genero,
	correo = v_mail,
	edad = v_edad,
	username = v_username,
	supervior_idf = v_super,
	department_idf = v_dept,
	puesto_idf = v_puesto,
	rol_idf = v_rol

	where nomina = v_nomina;
END;
$$;


ALTER PROCEDURE rh.spu_update_user(IN v_nomina integer, IN v_nombre character varying, IN v_appaterno character varying, IN v_apmaterno character varying, IN v_genero character varying, IN v_mail character varying, IN v_edad integer, IN v_username character varying, IN v_super integer, IN v_dept integer, IN v_puesto integer, IN v_rol integer) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 17548)
-- Name: fn_getcategorias(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getcategorias() RETURNS TABLE(id_cat integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT t.idcat AS id,
	t.descripcion AS descripcion
	FROM tickets.categorias t
	WHERE t.visible = 1;
END;
$$;


ALTER FUNCTION tickets.fn_getcategorias() OWNER TO postgres;

--
-- TOC entry 324 (class 1255 OID 17608)
-- Name: fn_getestatus(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getestatus() RETURNS TABLE(v_id_estatus integer, v_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	e.idestatus,
	e.descripcion
FROM tickets.estatus e
WHERE visible = 1
ORDER BY e.idestatus
;
END;
$$;


ALTER FUNCTION tickets.fn_getestatus() OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 17551)
-- Name: fn_getfallos(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getfallos(v_subcat integer) RETURNS TABLE(id_fallo integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT f.falloid AS id,
	f.descripcion AS descripcion
	FROM tickets.fallos f
	LEFT JOIN tickets.subcategoria s ON (f.subcatidf = s.idsubcat)
	WHERE f.visible = 1 and f.subcatidf = v_subcat;
END;
$$;


ALTER FUNCTION tickets.fn_getfallos(v_subcat integer) OWNER TO postgres;

--
-- TOC entry 323 (class 1255 OID 17616)
-- Name: fn_getpersonalit(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getpersonalit() RETURNS TABLE(id_user integer, username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	u.iduser,
	u.username
FROM tickets.users u
WHERE u.rolidf = 1;
END;
$$;


ALTER FUNCTION tickets.fn_getpersonalit() OWNER TO postgres;

--
-- TOC entry 325 (class 1255 OID 17610)
-- Name: fn_getprioridades(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getprioridades() RETURNS TABLE(v_idprioridad integer, v_descripcion character varying, v_maxdias integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	p.idprioridad,
	p.descripcion,
	p.maxdias
FROM tickets.prioridades p
WHERE visible = 1;
END;
$$;


ALTER FUNCTION tickets.fn_getprioridades() OWNER TO postgres;

--
-- TOC entry 320 (class 1255 OID 17597)
-- Name: fn_getsidebar(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getsidebar(v_nomina integer) RETURNS TABLE(descripcion character varying, style character varying, url text, icon character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
v_isAdmin integer := (select rolidf from tickets.users where nomina = v_nomina);
BEGIN
	IF v_nomina = 0 THEN
		RETURN QUERY
		SELECT
			md.descripcion,
			md.style,
			md.url,
			md.icon
		FROM tickets.menu_sidebar md
		WHERE md.sesionflag = 0;
	ELSE
		RETURN QUERY
		SELECT
			md.descripcion,
			md.style,
			md.url,
			md.icon
		FROM tickets.menu_sidebar md
		WHERE md.sesionflag <> 0
		AND md.rolidf = CASE 
							WHEN md.rolidf = 0 THEN rolidf
							WHEN v_isAdmin = 1 THEN rolidf
							ELSE 0
						END
		ORDER BY orden				
		;
	END IF;
END;
$$;


ALTER FUNCTION tickets.fn_getsidebar(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 17550)
-- Name: fn_getsubcategorias(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getsubcategorias(v_cat integer) RETURNS TABLE(id_subcat integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT s.idsubcat AS id,
	s.descripcion AS descripcion
	FROM tickets.subcategoria s
	LEFT JOIN tickets.categorias c ON (s.catidf = c.idcat)
	WHERE s.visible = 1 AND s.catidf =v_cat;
END;
$$;


ALTER FUNCTION tickets.fn_getsubcategorias(v_cat integer) OWNER TO postgres;

--
-- TOC entry 326 (class 1255 OID 17611)
-- Name: fn_getticketbyid(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getticketbyid(v_idticket integer) RETURNS TABLE(v_usuario text, v_titulo character varying, v_categoria character varying, v_subcategoria character varying, v_fallo character varying, v_estatusid integer, v_prioridadid integer, v_descripcion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
CONCAT(ru.nombre, ' ', ru.ape_paterno) as nombre,
td.titulo as titulo,
c.descripcion as categoria,
s.descripcion as subcategoria,
f.descripcion as fallo,
td.estatusidf as estatusid,
td.prioridadlevel as prioridad,
td.descripcion as descripcion
FROM tickets.ticket_data td
LEFT JOIN tickets.categorias c ON(td.categoriaidf = c.idcat)
LEFT JOIN tickets.subcategoria s ON(td.subcategoriaidf = s.idsubcat)
LEFT JOIN tickets.fallos f ON(td.falloidf = f.falloid)
LEFT JOIN rh.users ru ON(td.useridf=ru.nomina) --creador
LEFT JOIN tickets.users tu ON(td.responsable = tu.iduser)

WHERE td.idticket = v_idticket
;
END;
$$;


ALTER FUNCTION tickets.fn_getticketbyid(v_idticket integer) OWNER TO postgres;

--
-- TOC entry 322 (class 1255 OID 17602)
-- Name: fn_getticketreport(date, date, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getticketreport(date1 date, date2 date, id_cat integer, id_subcat integer, id_fallo integer, id_prioridad integer, id_status integer) RETURNS TABLE(v_idtikcet integer, v_titulo character varying, v_usuario text, v_categoria character varying, v_subcategoria character varying, v_fallo character varying, v_date text, v_prioridad character varying, responsable character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT

	td.idticket as idticket,
	td.titulo as titulo,
	--td.useridf as nomina,
	CONCAT(ru.nombre, ' ', ru.ape_paterno) as usuario,
	c.descripcion as categoria,
	s.descripcion as subcategoria,
	f.descripcion as fallo,
	TO_CHAR(td.fecha_creacion, 'DD/MM/YYYY') as fecha,
	p.descripcion as prioridades,
	CASE 
		WHEN tu.username IS NULL THEN 'Sin asignar'
		ELSE tu.username END
	as responsable
	
FROM tickets.ticket_data td
LEFT JOIN tickets.categorias c ON (td.categoriaidf = c.idcat)
LEFT JOIN tickets.subcategoria s ON (td.subcategoriaidf = s.idsubcat)
LEFT JOIN tickets.fallos f ON (td.falloidf = f.falloid)
LEFT JOIN tickets.prioridades p ON (td.prioridadlevel = p.idprioridad)
LEFT JOIN rh.users ru ON (td.useridf = ru.nomina)
LEFT JOIN tickets.users tu ON (td.responsable = tu.iduser)

WHERE TO_CHAR(td.fecha_creacion, 'DD/MM/YYYY')::date BETWEEN date1::date AND date2::date
/*AND (td.categoriaidf = id_cat OR id_cat = 0)
AND (td.subcategoriaidf = id_subcat OR id_subcat = 0)
AND (td.falloidf = id_fallo OR id_fallo = 0)
AND (td.prioridadlevel = id_prioridad OR id_prioridad = 0)
AND (td.estatusidf = id_status OR id_status = 0)*/;

END;
$$;


ALTER FUNCTION tickets.fn_getticketreport(date1 date, date2 date, id_cat integer, id_subcat integer, id_fallo integer, id_prioridad integer, id_status integer) OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 17590)
-- Name: fn_login(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_login(v_nomina integer) RETURNS TABLE(nomina integer, nombre text, rol character varying, v_hash text)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
RETURN QUERY
	SELECT
		tu.nomina,
		CONCAT(ru.nombre, ' ', ru.ape_paterno),
		r.descripcion,
		ru.hash_pass
	FROM tickets.users tu
	LEFT JOIN rh.users ru ON (tu.nomina=ru.nomina)
	LEFT JOIN tickets.roles r ON(tu.rolidf=r.rolid)
	WHERE tu.nomina = v_nomina;
END;
$$;


ALTER FUNCTION tickets.fn_login(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 17587)
-- Name: login(integer); Type: PROCEDURE; Schema: tickets; Owner: postgres
--

CREATE PROCEDURE tickets.login(IN v_nomina integer, OUT v_estatus integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
v_exist integer := (select count(*) from tickets.users u1 where u1.nomina = v_nomina);
v_reset integer := (select reset from rh.users u2 where u2.nomina = v_nomina);
BEGIN
	IF v_exist = 1 THEN
		IF v_reset = 1 THEN
			v_estatus:=1;
		ELSE
			v_estatus:=2;
		END IF;
	ELSE
		v_estatus := 0;
	END IF;
END;
$$;


ALTER PROCEDURE tickets.login(IN v_nomina integer, OUT v_estatus integer) OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 17591)
-- Name: spi_crearticket(integer, integer, integer, integer, text, character varying); Type: PROCEDURE; Schema: tickets; Owner: postgres
--

CREATE PROCEDURE tickets.spi_crearticket(IN v_nomina integer, IN v_categoria integer, IN v_subcat integer, IN v_fallo integer, IN v_descripcion text, IN v_titulo character varying, OUT v_idticket integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD-MM-YYYY HH24:MI:SS');
--v_idticket integer;
BEGIN
	INSERT INTO tickets.ticket_data(useridf, titulo, fecha, fecha_creacion, categoriaidf, subcategoriaidf, falloidf, estatusidf, descripcion, prioridadlevel)
	VALUES (v_nomina, v_titulo, today, today, v_categoria, v_subcat, v_fallo, 1, v_descripcion, 0)
	RETURNING idticket INTO v_idticket;
	INSERT INTO tickets.ticket_log(ticketidf, fecha, comment, estatusidf)
	VALUES (v_idticket, today, 'NUEVO', 1);
END;
$$;


ALTER PROCEDURE tickets.spi_crearticket(IN v_nomina integer, IN v_categoria integer, IN v_subcat integer, IN v_fallo integer, IN v_descripcion text, IN v_titulo character varying, OUT v_idticket integer) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 17595)
-- Name: sps_getmaildata(integer); Type: PROCEDURE; Schema: tickets; Owner: postgres
--

CREATE PROCEDURE tickets.sps_getmaildata(IN v_nomina integer, OUT nombre text, OUT correo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
SELECT
	INTO nombre, correo
	CONCAT(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno) as nombre,
	u.correo
FROM rh.users u
WHERE u.nomina = v_nomina;
END;
$$;


ALTER PROCEDURE tickets.sps_getmaildata(IN v_nomina integer, OUT nombre text, OUT correo character varying) OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 17617)
-- Name: spu_updateticket(integer, integer, integer, text, integer, integer); Type: PROCEDURE; Schema: tickets; Owner: postgres
--

CREATE PROCEDURE tickets.spu_updateticket(IN v_idticket integer, IN v_idestatus integer, IN v_idprioridad integer, IN v_comentario text, IN v_useridf integer, IN v_responsable integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD-MM-YYYY HH24:MI:SS');
BEGIN
UPDATE tickets.ticket_data SET
	estatusidf = v_idestatus,
	prioridadlevel = v_idprioridad,
	fecha = today,
	usermodify = v_useridf,
	responsable = v_responsable
WHERE idticket = v_idTicket
;

INSERT INTO tickets.ticket_log(ticketidf, fecha, estatusidf, comment, useridf)
VALUES (v_idTicket, today, v_idestatus, v_comentario, v_useridf);
COMMIT;
END;
$$;


ALTER PROCEDURE tickets.spu_updateticket(IN v_idticket integer, IN v_idestatus integer, IN v_idprioridad integer, IN v_comentario text, IN v_useridf integer, IN v_responsable integer) OWNER TO postgres;

--
-- TOC entry 328 (class 1255 OID 17618)
-- Name: ticket_log(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.ticket_log(id_ticket integer) RETURNS TABLE(v_fecha timestamp without time zone, v_comentario text, v_user character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
SELECT
tl.fecha,
tl.comment,
CONCAT(u.nombre, ' ', u.ape_paterno)
FROM tickets.ticket_log tl
JOIN rh.users u ON(tl.useridf = u.nomina)
WHERE tl.ticketidf = id_ticket
;
END;
$$;


ALTER FUNCTION tickets.ticket_log(id_ticket integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 239 (class 1259 OID 17438)
-- Name: v_reset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.v_reset (
    reset integer
);


ALTER TABLE public.v_reset OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17325)
-- Name: acompanantes; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.acompanantes (
    incidencia_df integer CONSTRAINT acompanantes_incidenciai_df_not_null NOT NULL,
    nomina integer,
    telefono character varying(12),
    acomp integer
);


ALTER TABLE rh.acompanantes OWNER TO "RH";

--
-- TOC entry 223 (class 1259 OID 17329)
-- Name: departaments; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.departaments (
    id_departamento integer NOT NULL,
    departamento character varying(50),
    visible boolean
);


ALTER TABLE rh.departaments OWNER TO "RH";

--
-- TOC entry 224 (class 1259 OID 17333)
-- Name: incidencia_data; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.incidencia_data (
    id integer NOT NULL,
    useridf integer,
    motivoidf integer,
    goceidf integer,
    vacacionesflag integer,
    tipoautoidf integer,
    placas character varying(50),
    lugar character varying(200),
    telefono character varying(15),
    dias_qty integer,
    fecha_ini date,
    fecha_fin date,
    fecha_creacion timestamp without time zone,
    autoriza_flag integer,
    vobo_flag integer,
    descripcion text,
    observaciones text,
    regresa_flag integer,
    acompanantes_qty integer,
    hora_salida character varying,
    hora_regreso character varying,
    tipo integer
);


ALTER TABLE rh.incidencia_data OWNER TO "RH";

--
-- TOC entry 225 (class 1259 OID 17339)
-- Name: incidencia_log; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.incidencia_log (
    id integer NOT NULL,
    incidenciaidf integer,
    fecha timestamp without time zone,
    user_modify integer,
    comment text
);


ALTER TABLE rh.incidencia_log OWNER TO "RH";

--
-- TOC entry 226 (class 1259 OID 17345)
-- Name: incidencias; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.incidencias (
    id integer NOT NULL,
    descripcion character varying(100),
    visible integer
);


ALTER TABLE rh.incidencias OWNER TO "RH";

--
-- TOC entry 227 (class 1259 OID 17349)
-- Name: menu_data; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.menu_data (
    id_menu integer NOT NULL,
    descripcion character varying(100),
    texto text,
    rolidf integer,
    style text,
    url text,
    sesionflag integer,
    orden integer,
    icon character varying(100)
);


ALTER TABLE rh.menu_data OWNER TO "RH";

--
-- TOC entry 228 (class 1259 OID 17355)
-- Name: motivos; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.motivos (
    id integer NOT NULL,
    descripcion character varying(100),
    tipoincidenciaidf integer,
    visible integer
);


ALTER TABLE rh.motivos OWNER TO "RH";

--
-- TOC entry 229 (class 1259 OID 17359)
-- Name: puestos; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.puestos (
    id integer NOT NULL,
    descripcion character varying,
    visible integer
);


ALTER TABLE rh.puestos OWNER TO "RH";

--
-- TOC entry 230 (class 1259 OID 17365)
-- Name: roles; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.roles (
    rolid integer NOT NULL,
    description character varying(50),
    visible numeric(2,0)
);


ALTER TABLE rh.roles OWNER TO "RH";

--
-- TOC entry 231 (class 1259 OID 17369)
-- Name: sec_departamentos; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_departamentos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE rh.sec_departamentos OWNER TO "RH";

--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 231
-- Name: sec_departamentos; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_departamentos OWNED BY rh.departaments.id_departamento;


--
-- TOC entry 232 (class 1259 OID 17370)
-- Name: sec_incidencias; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_incidencias
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE rh.sec_incidencias OWNER TO "RH";

--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 232
-- Name: sec_incidencias; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_incidencias OWNED BY rh.incidencia_data.id;


--
-- TOC entry 233 (class 1259 OID 17371)
-- Name: sec_incidencias_log; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_incidencias_log
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 1;


ALTER SEQUENCE rh.sec_incidencias_log OWNER TO "RH";

--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 233
-- Name: sec_incidencias_log; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_incidencias_log OWNED BY rh.incidencia_log.id;


--
-- TOC entry 234 (class 1259 OID 17372)
-- Name: sec_motivos; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_motivos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1;


ALTER SEQUENCE rh.sec_motivos OWNER TO "RH";

--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 234
-- Name: sec_motivos; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_motivos OWNED BY rh.motivos.id;


--
-- TOC entry 235 (class 1259 OID 17373)
-- Name: sec_puestos; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_puestos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE rh.sec_puestos OWNER TO "RH";

--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 235
-- Name: sec_puestos; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_puestos OWNED BY rh.puestos.id;


--
-- TOC entry 236 (class 1259 OID 17374)
-- Name: sec_roles; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_roles
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE rh.sec_roles OWNER TO "RH";

--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 236
-- Name: sec_roles; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_roles OWNED BY rh.roles.rolid;


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 236
-- Name: SEQUENCE sec_roles; Type: COMMENT; Schema: rh; Owner: RH
--

COMMENT ON SEQUENCE rh.sec_roles IS 'secuence for roles table';


--
-- TOC entry 237 (class 1259 OID 17375)
-- Name: users; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.users (
    user_id integer NOT NULL,
    nombre character varying(50),
    ape_paterno character varying(50),
    ape_materno character varying(50),
    genero character varying(4),
    correo character varying(50),
    edad numeric(4,0),
    supervior_idf integer,
    rol_idf integer,
    hash_pass text,
    department_idf integer,
    nomina integer,
    reset integer,
    username character varying(20),
    puesto_idf integer,
    admin_level integer
);


ALTER TABLE rh.users OWNER TO "RH";

--
-- TOC entry 238 (class 1259 OID 17381)
-- Name: sec_users; Type: SEQUENCE; Schema: rh; Owner: RH
--

CREATE SEQUENCE rh.sec_users
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1;


ALTER SEQUENCE rh.sec_users OWNER TO "RH";

--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 238
-- Name: sec_users; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_users OWNED BY rh.users.user_id;


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 238
-- Name: SEQUENCE sec_users; Type: COMMENT; Schema: rh; Owner: RH
--

COMMENT ON SEQUENCE rh.sec_users IS 'secuence for users table';


--
-- TOC entry 249 (class 1259 OID 17502)
-- Name: categorias; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.categorias (
    idcat integer NOT NULL,
    descripcion character varying(100),
    visible integer
);


ALTER TABLE tickets.categorias OWNER TO "TICKETSAPP";

--
-- TOC entry 256 (class 1259 OID 17552)
-- Name: estatus; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.estatus (
    idestatus integer NOT NULL,
    descripcion character varying(100),
    visible integer
);


ALTER TABLE tickets.estatus OWNER TO "TICKETSAPP";

--
-- TOC entry 253 (class 1259 OID 17517)
-- Name: fallos; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.fallos (
    falloid integer NOT NULL,
    descripcion character varying(100),
    subcatidf integer,
    visible integer
);


ALTER TABLE tickets.fallos OWNER TO "TICKETSAPP";

--
-- TOC entry 258 (class 1259 OID 17564)
-- Name: menu_sidebar; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.menu_sidebar (
    id integer NOT NULL,
    descripcion character varying(100),
    texto text,
    rolidf integer,
    style character varying(100),
    url text,
    sesionflag integer,
    orden integer,
    icon character varying(100)
);


ALTER TABLE tickets.menu_sidebar OWNER TO "TICKETSAPP";

--
-- TOC entry 257 (class 1259 OID 17558)
-- Name: prioridades; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.prioridades (
    idprioridad integer NOT NULL,
    descripcion character varying(100),
    maxdias integer,
    visible integer
);


ALTER TABLE tickets.prioridades OWNER TO "TICKETSAPP";

--
-- TOC entry 255 (class 1259 OID 17521)
-- Name: roles; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.roles (
    rolid integer CONSTRAINT roles_roldif_not_null NOT NULL,
    descripcion character varying(100),
    visible integer
);


ALTER TABLE tickets.roles OWNER TO "TICKETSAPP";

--
-- TOC entry 250 (class 1259 OID 17508)
-- Name: sec_categoria; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_categoria
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE tickets.sec_categoria OWNER TO "TICKETSAPP";

--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 250
-- Name: sec_categoria; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_categoria OWNED BY tickets.categorias.idcat;


--
-- TOC entry 254 (class 1259 OID 17520)
-- Name: sec_fallos; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_fallos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE tickets.sec_fallos OWNER TO "TICKETSAPP";

--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 254
-- Name: sec_fallos; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_fallos OWNED BY tickets.fallos.falloid;


--
-- TOC entry 252 (class 1259 OID 17515)
-- Name: sec_subcat; Type: SEQUENCE; Schema: tickets; Owner: postgres
--

CREATE SEQUENCE tickets.sec_subcat
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE tickets.sec_subcat OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17473)
-- Name: ticket_data; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.ticket_data (
    idticket integer NOT NULL,
    fecha timestamp without time zone,
    fecha_creacion timestamp without time zone,
    usermodify integer,
    responsable integer,
    categoriaidf integer,
    subcategoriaidf integer,
    falloidf integer,
    estatusidf integer,
    comentario text,
    descripcion text,
    prioridadlevel integer,
    titulo character varying(50),
    useridf integer
);


ALTER TABLE tickets.ticket_data OWNER TO "TICKETSAPP";

--
-- TOC entry 244 (class 1259 OID 17484)
-- Name: sec_ticket_data; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_ticket_data
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_ticket_data OWNER TO "TICKETSAPP";

--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 244
-- Name: sec_ticket_data; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_ticket_data OWNED BY tickets.ticket_data.idticket;


--
-- TOC entry 247 (class 1259 OID 17492)
-- Name: ticket_log; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.ticket_log (
    id integer NOT NULL,
    ticketidf integer,
    fecha timestamp without time zone,
    estatusidf integer,
    comment text,
    useridf integer
);


ALTER TABLE tickets.ticket_log OWNER TO "TICKETSAPP";

--
-- TOC entry 248 (class 1259 OID 17500)
-- Name: sec_ticket_log; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_ticket_log
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_ticket_log OWNER TO "TICKETSAPP";

--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 248
-- Name: sec_ticket_log; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_ticket_log OWNED BY tickets.ticket_log.id;


--
-- TOC entry 245 (class 1259 OID 17485)
-- Name: users; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.users (
    iduser integer NOT NULL,
    nomina integer,
    rolidf integer,
    username character varying(50)
);


ALTER TABLE tickets.users OWNER TO "TICKETSAPP";

--
-- TOC entry 246 (class 1259 OID 17491)
-- Name: sec_users; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_users
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1;


ALTER SEQUENCE tickets.sec_users OWNER TO "TICKETSAPP";

--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 246
-- Name: sec_users; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_users OWNED BY tickets.users.iduser;


--
-- TOC entry 251 (class 1259 OID 17509)
-- Name: subcategoria; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.subcategoria (
    idsubcat integer DEFAULT nextval('tickets.sec_subcat'::regclass) NOT NULL,
    descripcion character varying(100),
    catidf integer,
    visible integer
);


ALTER TABLE tickets.subcategoria OWNER TO "TICKETSAPP";

--
-- TOC entry 4868 (class 2604 OID 17382)
-- Name: departaments id_departamento; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.departaments ALTER COLUMN id_departamento SET DEFAULT nextval('rh.sec_departamentos'::regclass);


--
-- TOC entry 4869 (class 2604 OID 17383)
-- Name: incidencia_data id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_data ALTER COLUMN id SET DEFAULT nextval('rh.sec_incidencias'::regclass);


--
-- TOC entry 4870 (class 2604 OID 17384)
-- Name: incidencia_log id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_log ALTER COLUMN id SET DEFAULT nextval('rh.sec_incidencias_log'::regclass);


--
-- TOC entry 4871 (class 2604 OID 17385)
-- Name: motivos id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.motivos ALTER COLUMN id SET DEFAULT nextval('rh.sec_motivos'::regclass);


--
-- TOC entry 4872 (class 2604 OID 17386)
-- Name: puestos id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.puestos ALTER COLUMN id SET DEFAULT nextval('rh.sec_puestos'::regclass);


--
-- TOC entry 4873 (class 2604 OID 17387)
-- Name: roles rolid; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.roles ALTER COLUMN rolid SET DEFAULT nextval('rh.sec_roles'::regclass);


--
-- TOC entry 4874 (class 2604 OID 17388)
-- Name: users user_id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.users ALTER COLUMN user_id SET DEFAULT nextval('rh.sec_users'::regclass);


--
-- TOC entry 4878 (class 2604 OID 17535)
-- Name: categorias idcat; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.categorias ALTER COLUMN idcat SET DEFAULT nextval('tickets.sec_categoria'::regclass);


--
-- TOC entry 4880 (class 2604 OID 17531)
-- Name: fallos falloid; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.fallos ALTER COLUMN falloid SET DEFAULT nextval('tickets.sec_fallos'::regclass);


--
-- TOC entry 4875 (class 2604 OID 17528)
-- Name: ticket_data idticket; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_data ALTER COLUMN idticket SET DEFAULT nextval('tickets.sec_ticket_data'::regclass);


--
-- TOC entry 4877 (class 2604 OID 17529)
-- Name: ticket_log id; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_log ALTER COLUMN id SET DEFAULT nextval('tickets.sec_ticket_log'::regclass);


--
-- TOC entry 4876 (class 2604 OID 17527)
-- Name: users iduser; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.users ALTER COLUMN iduser SET DEFAULT nextval('tickets.sec_users'::regclass);


--
-- TOC entry 5083 (class 0 OID 17438)
-- Dependencies: 239
-- Data for Name: v_reset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.v_reset (reset) FROM stdin;
\N
\.


--
-- TOC entry 5066 (class 0 OID 17325)
-- Dependencies: 222
-- Data for Name: acompanantes; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.acompanantes (incidencia_df, nomina, telefono, acomp) FROM stdin;
2	4436	\N	1
2	1	\N	2
2	70	\N	3
12	70	\N	1
12	1312	\N	2
12	2	\N	3
12	3	\N	4
12	4	\N	5
32	2	\N	1
32	4436	\N	2
33	2	\N	1
33	4436	\N	2
34	2	\N	1
34	4436	\N	2
35	2	\N	1
35	4436	\N	2
36	4436	\N	1
37	4436	\N	1
\.


--
-- TOC entry 5067 (class 0 OID 17329)
-- Dependencies: 223
-- Data for Name: departaments; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.departaments (id_departamento, departamento, visible) FROM stdin;
1	Estampados	t
2	Ensambles	t
3	Diseño	t
4	Calidad	t
5	Seguridad e Higiene	t
6	Recursos Humanos	t
7	Sistemas	t
\.


--
-- TOC entry 5068 (class 0 OID 17333)
-- Dependencies: 224
-- Data for Name: incidencia_data; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.incidencia_data (id, useridf, motivoidf, goceidf, vacacionesflag, tipoautoidf, placas, lugar, telefono, dias_qty, fecha_ini, fecha_fin, fecha_creacion, autoriza_flag, vobo_flag, descripcion, observaciones, regresa_flag, acompanantes_qty, hora_salida, hora_regreso, tipo) FROM stdin;
37	4	1	2	\N	2	CVC-1234	POr hay	442315569	\N	\N	\N	2026-06-12 08:12:03	1	\N	Amonooos	Vete largooo	1	1	07:11	10:11	1
38	4436	6	\N	0	\N	\N	\N	1234567890	3	2026-06-11	2026-06-13	2026-06-12 11:20:30	0	0	saadsa	\N	\N	\N	\N	\N	2
6	1	8	2	1	\N	\N	\N	44232432	4	2026-06-09	2026-06-12	2026-06-04 07:58:38	1	1	Vacaciones	Sin goce	\N	\N	\N	\N	2
7	4436	12	1	1	\N	\N	\N	4423561	8	2026-06-09	2026-06-16	2026-06-04 08:01:13	1	1	Nacimiento de un hijo	Adelante	\N	\N	\N	\N	2
5	2	6	2	1	\N	\N	\N	442135212	10	2026-06-04	2026-06-13	2026-06-04 07:57:26	1	1	Incapacidad laboral	No autorizan goce	\N	\N	\N	\N	2
13	3	5	0	\N	1		Medico	4421345677	\N	\N	\N	2026-06-08 07:33:28	2	\N	Ya no se regresa	No se autoriza	0	0	10:33	00:00	1
8	70	5	2	\N	2	XXX-XXX	f&p	442135467	\N	\N	\N	2026-06-08 07:26:25	1	\N	Visita	Se autoriza la salida	1	0	09:00	12:30	1
12	3	3	0	\N	3	111-111-111	ZZZZZ	44213456789	\N	\N	\N	2026-06-08 07:31:35	2	\N	Visita a planta proveedor	No se autoriza	1	5	10:30	17:30	1
1	1312	1	2	\N	1		A Nissan	44321256	\N	\N	\N	2026-06-04 07:41:03	1	\N	Entrega urgente	Autorizado	1	0	10:00	15:30	1
3	4	3	0	\N	3	YYY-YYY-YYY	Mecánico	448723141	\N	\N	\N	2026-06-04 07:45:59	0	\N	Afincación de vehículo	Fuga la horga	0	0	10:00	0:00	1
2	3	5	2	\N	2	XXX-XXX-XXX	F&P	4428304862	\N	\N	\N	2026-06-04 07:43:33	1	\N	Salida de trabajo	Autorizado	1	3	10:00	15:42	1
43	4436	8	\N	1	\N	\N	\N	444223652	6	2026-06-11	2026-06-16	2026-06-12 12:30:43	0	0	Prueba de ausencia desde la web	\N	\N	\N	\N	\N	2
11	4	11	1	0	\N	\N	\N	4412345678	12	2026-06-09	2026-06-20	2026-06-08 07:29:39	1	1	Semanas por maternidad	Aprobado	\N	\N	\N	\N	2
10	1312	10	2	0	\N	\N	\N	44231556421	3	2026-06-09	2026-06-11	2026-06-08 07:28:45	1	1	Visita medica	Permiso sin goce	\N	\N	\N	\N	2
9	2	8	2	1	\N	\N	\N	44232432	5	2026-06-09	2026-06-13	2026-06-08 07:27:44	1	1	Vacaciones	Aprobado	\N	\N	\N	\N	2
4	4	7	1	1	\N	\N	\N	443255412	3	2026-06-03	2026-06-05	2026-06-04 07:56:43	1	1	Se solicitan vacaciones	Permiso de vacaciones	\N	\N	\N	\N	2
14	2	5	\N	\N	1	XXX-XXX	Mazda	4428304862	\N	\N	\N	2026-06-09 13:20:14	0	\N	Visita cliente	\N	1	0	10:19	13:19	1
15	4	5	\N	\N	1	XXX-XXX	zzzz	4428304862	\N	\N	\N	2026-06-09 13:22:39	0	\N	zzzzz	\N	1	0	13:22	14:22	1
16	4	5	\N	\N	1	XXX-XXX	ddd	4428304862	\N	\N	\N	2026-06-09 13:24:20	0	\N	ddd	\N	0	0	13:24	13:24	1
17	4	5	\N	\N	1	XXX-XXX	rrrr	4428304862	\N	\N	\N	2026-06-09 13:25:24	0	\N	rrrrrr	\N	0	0	13:25	13:25	1
18	4	5	\N	\N	1	XXX-XXX	rrrr	4428304862	\N	\N	\N	2026-06-09 13:25:59	0	\N	rrrrr	\N	0	0	13:25	13:25	1
19	2	1	\N	\N	1		xxxxxxxx	4428304862	\N	\N	\N	2026-06-09 13:26:41	0	\N	xxxxxxxxxxxx	\N	1	0	13:26	13:26	1
20	2	5	\N	\N	1		ssss	4428304862	\N	\N	\N	2026-06-09 13:30:34	0	\N	sssss	\N	0	0	13:30	13:30	1
21	4	2	\N	\N	2	XXX-XXX	tttttt	13213234	\N	\N	\N	2026-06-09 13:35:26	0	\N	ttttt	\N	0	0	13:35	13:35	1
22	4	5	\N	\N	1	XXX-XXX	zzz	13213234	\N	\N	\N	2026-06-09 13:38:41	0	\N	zzzz	\N	0	0	10:38	13:38	1
23	4	5	\N	\N	1	XXX-XXX	tttt	13213234	\N	\N	\N	2026-06-09 13:39:54	0	\N	tttt	\N	0	0	06:39	13:39	1
24	4	5	\N	\N	1	XXX-XXX	tttt	13213234	\N	\N	\N	2026-06-09 14:18:08	0	\N	tttt	\N	0	0	14:17	14:17	1
25	4	5	\N	\N	1	XXX-XXX	yyyy	13213234	\N	\N	\N	2026-06-09 15:04:20	0	\N	yyyyy	\N	1	0	15:04	15:04	1
26	4	5	\N	\N	1	XXX-XXX	yyyy	13213234	\N	\N	\N	2026-06-09 15:06:56	0	\N	yyyyy	\N	1	0	16:06	18:06	1
27	4	5	\N	\N	1	XXX-XXX	yyyy	13213234	\N	\N	\N	2026-06-09 15:07:33	0	\N	yyyyy	\N	1	0	10:07	16:07	1
28	4	6	\N	0	\N	\N	\N	4412345678	3	2026-06-02	2026-06-04	2026-06-09 16:09:54	0	0	Tttttt	\N	\N	\N	\N	\N	2
29	4	6	\N	0	\N	\N	\N	4412345678	3	2026-06-02	2026-06-04	2026-06-09 16:10:34	0	0	Tttttt	\N	\N	\N	\N	\N	2
31	4	6	\N	0	\N	\N	\N	4412345678	3	2026-06-02	2026-06-04	2026-06-09 16:11:29	0	0	Tttttt	\N	\N	\N	\N	\N	2
32	4	5	\N	\N	3	UPQ-5SP	Por hay	443612345	\N	\N	\N	2026-06-12 07:56:09	0	\N	Amonoooos	\N	1	2	08:55	16:55	1
33	4	5	\N	\N	3	UPQ-5SP	Por hay	443612345	\N	\N	\N	2026-06-12 07:56:42	0	\N	Amonoooos	\N	1	2	10:56	14:56	1
34	4	5	\N	\N	3	UPQ-5SP	Por hay	443612345	\N	\N	\N	2026-06-12 07:58:09	0	\N	Amonoooos	\N	1	2	09:57	11:58	1
35	4	5	\N	\N	3	UPQ-5SP	Por hay	443612345	\N	\N	\N	2026-06-12 08:00:05	0	\N	Amonoooos	\N	1	2	07:59	16:59	1
36	4	1	\N	\N	2	CVC-1234	POr hay	442315569	\N	\N	\N	2026-06-12 08:08:53	0	\N	Amonooos	\N	1	1	08:08	10:08	1
41	4436	5	2	\N	1		Prueba	4412345678	\N	\N	\N	2026-06-12 12:16:19	2	\N	Prueba desde servidor 11 jijijiji	Esto es una prueba para actualizar desde el servidor... veamos que pasa!!!	1	0	11:16	15:16	1
42	4436	5	1	\N	1		Prueba	4412345678	\N	\N	\N	2026-06-12 12:29:11	1	\N	Prueba desde servidor 11 nuevamente	otrsa	1	0	07:17	12:17	1
40	4436	5	1	\N	1		Prueba	4412345678	\N	\N	\N	2026-06-12 11:37:24	1	\N	Prueba desde servidor	Otra mas	1	0	12:37	15:37	1
39	4436	5	2	\N	1		Prueba	4412345678	\N	\N	\N	2026-06-12 11:35:38	2	\N	Prueba desde servidor	Mas pruebas	1	0	11:35	12:35	1
30	4	6	0	0	\N	\N	\N	4412345678	3	2026-06-02	2026-06-04	2026-06-09 16:11:13	0	0	Tttttt	Pruebis	\N	\N	\N	\N	2
\.


--
-- TOC entry 5069 (class 0 OID 17339)
-- Dependencies: 225
-- Data for Name: incidencia_log; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.incidencia_log (id, incidenciaidf, fecha, user_modify, comment) FROM stdin;
1	1	2026-06-04 07:41:03	1312	NUEVO
2	2	2026-06-04 07:43:33	3	NUEVO
3	3	2026-06-04 07:45:59	4	NUEVO
4	4	2026-06-04 07:56:43	4	NUEVO
5	5	2026-06-04 07:57:26	2	NUEVO
6	6	2026-06-04 07:58:38	1	NUEVO
7	7	2026-06-04 08:01:13	4436	NUEVO
8	7	2026-06-04 11:08:06	1	Adelante
9	6	2026-06-04 12:12:21	1	Sin goce
10	6	2026-06-04 12:12:21	1	Sin goce
11	4	2026-06-04 15:43:05	4436	\N
12	5	2026-06-04 16:03:02	4436	No autorizan goce
13	8	2026-06-08 07:26:25	70	NUEVO
14	9	2026-06-08 07:27:44	2	NUEVO
15	10	2026-06-08 07:28:45	1312	NUEVO
16	11	2026-06-08 07:29:39	4	NUEVO
17	12	2026-06-08 07:31:35	3	NUEVO
18	13	2026-06-08 07:33:28	3	NUEVO
19	13	2026-06-08 07:39:14	\N	No se autoriza
20	8	2026-06-08 07:40:36	\N	Se autoriza la salida
21	12	2026-06-08 07:41:29	\N	No se autoriza
22	1	2026-06-08 07:41:51	\N	Autorizado
23	3	2026-06-08 07:42:07	\N	Fuga la horga
24	2	2026-06-08 07:42:27	\N	Autorizado
25	11	2026-06-08 07:47:30	4436	Aprobado
26	11	2026-06-08 07:47:45	4436	Aprobado
27	10	2026-06-08 07:48:29	4436	Permiso sin goce
28	9	2026-06-08 07:49:15	4436	Aprobado
29	4	2026-06-08 07:49:39	4436	Permiso de vacaciones
30	14	2026-06-09 13:20:14	2	NUEVO
31	15	2026-06-09 13:22:39	4	NUEVO
32	16	2026-06-09 13:24:20	4	NUEVO
33	17	2026-06-09 13:25:24	4	NUEVO
34	18	2026-06-09 13:25:59	4	NUEVO
35	19	2026-06-09 13:26:41	2	NUEVO
36	20	2026-06-09 13:30:34	2	NUEVO
37	21	2026-06-09 13:35:26	4	NUEVO
38	22	2026-06-09 13:38:41	4	NUEVO
39	23	2026-06-09 13:39:54	4	NUEVO
40	24	2026-06-09 14:18:08	4	NUEVO
41	25	2026-06-09 15:04:20	4	NUEVO
42	26	2026-06-09 15:06:56	4	NUEVO
43	27	2026-06-09 15:07:33	4	NUEVO
44	28	2026-06-09 16:09:54	4	NUEVO
45	29	2026-06-09 16:10:34	4	NUEVO
46	30	2026-06-09 16:11:13	4	NUEVO
47	31	2026-06-09 16:11:29	4	NUEVO
48	32	2026-06-12 07:56:09	4	NUEVO
49	33	2026-06-12 07:56:42	4	NUEVO
50	34	2026-06-12 07:58:09	4	NUEVO
51	35	2026-06-12 08:00:05	4	NUEVO
52	36	2026-06-12 08:08:53	4	NUEVO
53	37	2026-06-12 08:12:03	4	NUEVO
54	37	2026-06-12 08:16:56	\N	Vete largooo
55	38	2026-06-12 11:20:30	4436	NUEVO
56	39	2026-06-12 11:35:38	4436	NUEVO
57	40	2026-06-12 11:37:24	4436	NUEVO
58	41	2026-06-12 12:16:19	4436	NUEVO
59	42	2026-06-12 12:29:11	4436	NUEVO
60	43	2026-06-12 12:30:43	4436	NUEVO
61	41	2026-06-15 10:22:49	\N	Esto es una prueba para actualizar desde el servidor... veamos que pasa!!!
62	42	2026-06-15 10:30:44	\N	otrsa
63	40	2026-06-15 15:08:52	\N	Otra mas
64	39	2026-06-15 15:11:38	4436	Mas pruebas
65	30	2026-06-15 15:55:00	4436	Pruebis
\.


--
-- TOC entry 5070 (class 0 OID 17345)
-- Dependencies: 226
-- Data for Name: incidencias; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.incidencias (id, descripcion, visible) FROM stdin;
\.


--
-- TOC entry 5071 (class 0 OID 17349)
-- Dependencies: 227
-- Data for Name: menu_data; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.menu_data (id_menu, descripcion, texto, rolidf, style, url, sesionflag, orden, icon) FROM stdin;
1	Inicio	Este modulo es el inicio y es para todos, todos lo pueden ver	0	\N	/rh	0	1	\N
5	Usuarios	\N	1	\N	/rh/usuarios	1	5	\N
6	Login	\N	\N	\N	/rh/login	0	2	\N
2	Cerrar Sesion	Es el logout, visible cuando se inicia sesion	0	\N	\N	1	7	\N
3	Reporte	\N	1	\N	/rh/reporte_incidencias	1	3	\N
7	Incidencias	\N	0	\N	/rh/incidencias	1	1	\N
4	Vigilancia	\N	0	\N	/rh/vigilancia	0	6	\N
\.


--
-- TOC entry 5072 (class 0 OID 17355)
-- Dependencies: 228
-- Data for Name: motivos; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.motivos (id, descripcion, tipoincidenciaidf, visible) FROM stdin;
5	Salida de trabajo	2	1
1	Entrega de material	2	1
2	Salida de trabajo	2	1
3	Visita a proveedor	2	1
4	Visita a cliente	2	1
6	Accidente laboral	1	1
7	Vacaciones	1	1
8	Nacimiento de un hijo	1	1
9	Escolar	1	1
10	Enfermedad	1	1
11	Maternidad	1	1
12	Paternidad	1	1
\.


--
-- TOC entry 5073 (class 0 OID 17359)
-- Dependencies: 229
-- Data for Name: puestos; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.puestos (id, descripcion, visible) FROM stdin;
1	Gerente	1
2	Supervisor	1
3	Operador	1
4	Ingeniero	1
5	Coordinador	1
6	Director	1
\.


--
-- TOC entry 5074 (class 0 OID 17365)
-- Dependencies: 230
-- Data for Name: roles; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.roles (rolid, description, visible) FROM stdin;
1	Administrador	1
2	Usuario	1
\.


--
-- TOC entry 5081 (class 0 OID 17375)
-- Dependencies: 237
-- Data for Name: users; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.users (user_id, nombre, ape_paterno, ape_materno, genero, correo, edad, supervior_idf, rol_idf, hash_pass, department_idf, nomina, reset, username, puesto_idf, admin_level) FROM stdin;
9	Juan	Sánchez	Pérez	M	jp-sanchez@fegq.com.mx	25	0	1	$2b$10$J3wZn5vh9/IFw98KXsh8reEIwSqEgCaqetRdByUiYaiHdMQjzv.H2	\N	4436	0	\N	\N	\N
14	Emiliano	Zamora	Trujillo	M	\N	20	2	2	\N	4	2	1	ezamora	4	\N
12	Erendira	Rendon		F	\N	0	70	2	\N	6	1312	1	erendon	4	\N
13	Jorge	Hernandez	Espinoza	M	\N	35	1	2	\N	4	3	1	johernandez	5	\N
15	Brenda	Lerma	Perez	F	\N	24	1	2	\N	3	4	1	blerma	5	\N
10	admin	a	a	M	\N	50	4436	1	$2b$10$4dY29zeeMncpSXwapyK8f.NJLX/iBan5kse3VbKx1fXjaal3MbcGa	2	1	0	admin	2	\N
11	Aristides	Camacho		M	\N	68	0	2	$2b$10$s4oO52kwD5oTgGO9.aY7H.fILOR4GsyV8R55MUdneXrwnT1dUqf.2	6	70	0	acamacho	6	\N
\.


--
-- TOC entry 5090 (class 0 OID 17502)
-- Dependencies: 249
-- Data for Name: categorias; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.categorias (idcat, descripcion, visible) FROM stdin;
1	Software	1
2	Hardware	1
3	Red	1
\.


--
-- TOC entry 5097 (class 0 OID 17552)
-- Dependencies: 256
-- Data for Name: estatus; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.estatus (idestatus, descripcion, visible) FROM stdin;
4	Finalizado	1
3	En proceso	1
2	Asignado	1
1	Nuevo	1
\.


--
-- TOC entry 5094 (class 0 OID 17517)
-- Dependencies: 253
-- Data for Name: fallos; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.fallos (falloid, descripcion, subcatidf, visible) FROM stdin;
1	Dar de baja scrap	5	1
2	Usuario	5	1
3	Otro	1	1
4	CAD	1	1
5	MCOSMOS	1	1
6	Office 365	1	1
7	VNC media	1	1
8	Cable en mal estado	2	1
9	Sin internet	3	1
10	Recuperar archivo	4	1
11	Acceso	4	1
12	Instalacion	5	1
13	Alta de PN	5	1
14	Cambio de PO	8	1
15	Alta de usuario	8	1
16	Mouse no funciona	7	1
17	Teclado con fallas	7	1
18	Mouse roto	7	1
\.


--
-- TOC entry 5099 (class 0 OID 17564)
-- Dependencies: 258
-- Data for Name: menu_sidebar; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.menu_sidebar (id, descripcion, texto, rolidf, style, url, sesionflag, orden, icon) FROM stdin;
1	Inicio	\N	2	\N	\N	0	1	bi bi-house
2	Login	\N	2	\N	\N	0	2	bi bi-person-badge-fill
3	Usuarios	\N	1	\N	/tickets/usuarios	1	3	bi bi-people-fill
4	Dashboard	\N	2	\N	\N	1	4	\N
\.


--
-- TOC entry 5098 (class 0 OID 17558)
-- Dependencies: 257
-- Data for Name: prioridades; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.prioridades (idprioridad, descripcion, maxdias, visible) FROM stdin;
1	Baja	15	1
2	Media	8	1
3	Alta	4	1
4	Urgente	1	1
\.


--
-- TOC entry 5096 (class 0 OID 17521)
-- Dependencies: 255
-- Data for Name: roles; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.roles (rolid, descripcion, visible) FROM stdin;
2	Usuario	1
1	Administrador	1
\.


--
-- TOC entry 5092 (class 0 OID 17509)
-- Dependencies: 251
-- Data for Name: subcategoria; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.subcategoria (idsubcat, descripcion, catidf, visible) FROM stdin;
1	Instalación de software	1	1
2	Infraestructura	3	1
3	Conexión	3	1
4	Carpetas	3	1
5	Epicor	1	1
6	Equipo de computo	2	1
7	Perifericos (teclado, mouse, etc.)	2	1
8	Proveedores	1	1
\.


--
-- TOC entry 5084 (class 0 OID 17473)
-- Dependencies: 243
-- Data for Name: ticket_data; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.ticket_data (idticket, fecha, fecha_creacion, usermodify, responsable, categoriaidf, subcategoriaidf, falloidf, estatusidf, comentario, descripcion, prioridadlevel, titulo, useridf) FROM stdin;
1	2026-06-23 15:08:29	2026-06-01 15:08:29	\N	\N	1	2	1	1	\N	Testing	0	Testing x2	4436
3	2026-06-24 14:48:04	2026-06-24 14:48:04	\N	\N	\N	\N	\N	1	\N	\N	0		4436
4	2026-06-24 14:55:34	2026-06-24 14:55:34	\N	\N	1	1	3	1	\N		0	Otra prueba	4436
5	2026-06-24 14:56:45	2026-06-24 14:56:45	\N	\N	1	1	3	1	\N		0	Otra maaas	4436
6	2026-06-24 15:02:03	2026-06-24 15:02:03	\N	\N	1	1	5	1	\N		0	Otra mas	4436
7	2026-06-24 15:05:29	2026-06-24 15:05:29	\N	\N	1	1	7	1	\N		0	La ultima de hoy chachauuu	4436
8	2026-06-24 15:08:27	2026-06-24 15:08:27	\N	\N	1	1	4	1	\N	dsadasd	0	dasd	4436
9	2026-06-24 15:09:07	2026-06-24 15:09:07	\N	\N	2	7	17	1	\N	jjffjg	0	dasda	4436
2	2026-06-26 12:22:46	2026-06-23 15:08:33	4436	2	1	2	1	4	\N	Testing	2	Testing x2	4436
\.


--
-- TOC entry 5088 (class 0 OID 17492)
-- Dependencies: 247
-- Data for Name: ticket_log; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.ticket_log (id, ticketidf, fecha, estatusidf, comment, useridf) FROM stdin;
1	1	2026-06-23 15:08:29	1	NUEVO	\N
2	2	2026-06-23 15:08:33	1	NUEVO	\N
3	3	2026-06-24 14:48:04	1	NUEVO	\N
4	4	2026-06-24 14:55:34	1	NUEVO	\N
5	5	2026-06-24 14:56:45	1	NUEVO	\N
6	6	2026-06-24 15:02:03	1	NUEVO	\N
7	7	2026-06-24 15:05:29	1	NUEVO	\N
8	8	2026-06-24 15:08:27	1	NUEVO	\N
9	9	2026-06-24 15:09:07	1	NUEVO	\N
10	\N	2026-06-26 12:11:52	\N	\N	\N
11	2	2026-06-26 12:14:06	\N	\N	\N
12	2	2026-06-26 12:15:32	\N	\N	\N
13	2	2026-06-26 12:17:08	\N	\N	\N
14	2	2026-06-26 12:18:42	2	aaaaaaaaa	4436
15	2	2026-06-26 12:20:07	4	Finiched :D	4436
16	2	2026-06-26 12:22:26	4	Finiched :D	4436
17	2	2026-06-26 12:22:46	4	Finiched :D	4436
\.


--
-- TOC entry 5086 (class 0 OID 17485)
-- Dependencies: 245
-- Data for Name: users; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.users (iduser, nomina, rolidf, username) FROM stdin;
1	1	1	Usuario1
2	4436	1	sanch0d
\.


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 231
-- Name: sec_departamentos; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_departamentos', 7, true);


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 232
-- Name: sec_incidencias; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_incidencias', 43, true);


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 233
-- Name: sec_incidencias_log; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_incidencias_log', 65, true);


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 234
-- Name: sec_motivos; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_motivos', 12, true);


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 235
-- Name: sec_puestos; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_puestos', 6, true);


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 236
-- Name: sec_roles; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_roles', 2, true);


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 238
-- Name: sec_users; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_users', 15, true);


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 250
-- Name: sec_categoria; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_categoria', 3, true);


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 254
-- Name: sec_fallos; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_fallos', 18, true);


--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 252
-- Name: sec_subcat; Type: SEQUENCE SET; Schema: tickets; Owner: postgres
--

SELECT pg_catalog.setval('tickets.sec_subcat', 8, true);


--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 244
-- Name: sec_ticket_data; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_ticket_data', 9, true);


--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 248
-- Name: sec_ticket_log; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_ticket_log', 17, true);


--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 246
-- Name: sec_users; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_users', 2, true);


--
-- TOC entry 4882 (class 2606 OID 17432)
-- Name: departaments departaments_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.departaments
    ADD CONSTRAINT departaments_pkey PRIMARY KEY (id_departamento);


--
-- TOC entry 4884 (class 2606 OID 17416)
-- Name: incidencia_data incidencia_data_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_data
    ADD CONSTRAINT incidencia_data_pkey PRIMARY KEY (id);


--
-- TOC entry 4886 (class 2606 OID 17430)
-- Name: incidencia_log incidencia_log_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_log
    ADD CONSTRAINT incidencia_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4888 (class 2606 OID 17428)
-- Name: incidencias incidencias_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencias
    ADD CONSTRAINT incidencias_pkey PRIMARY KEY (id);


--
-- TOC entry 4890 (class 2606 OID 17426)
-- Name: menu_data menu_data_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.menu_data
    ADD CONSTRAINT menu_data_pkey PRIMARY KEY (id_menu);


--
-- TOC entry 4892 (class 2606 OID 17424)
-- Name: motivos motivos_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.motivos
    ADD CONSTRAINT motivos_pkey PRIMARY KEY (id);


--
-- TOC entry 4894 (class 2606 OID 17422)
-- Name: puestos puestos_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.puestos
    ADD CONSTRAINT puestos_pkey PRIMARY KEY (id);


--
-- TOC entry 4896 (class 2606 OID 17420)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rolid);


--
-- TOC entry 4898 (class 2606 OID 17418)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4906 (class 2606 OID 17507)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (idcat);


--
-- TOC entry 4914 (class 2606 OID 17557)
-- Name: estatus estatus_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.estatus
    ADD CONSTRAINT estatus_pkey PRIMARY KEY (idestatus);


--
-- TOC entry 4910 (class 2606 OID 17534)
-- Name: fallos fallos_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.fallos
    ADD CONSTRAINT fallos_pkey PRIMARY KEY (falloid);


--
-- TOC entry 4918 (class 2606 OID 17571)
-- Name: menu_sidebar menu_sidebar_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.menu_sidebar
    ADD CONSTRAINT menu_sidebar_pkey PRIMARY KEY (id);


--
-- TOC entry 4916 (class 2606 OID 17563)
-- Name: prioridades prioridades_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.prioridades
    ADD CONSTRAINT prioridades_pkey PRIMARY KEY (idprioridad);


--
-- TOC entry 4912 (class 2606 OID 17526)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rolid);


--
-- TOC entry 4908 (class 2606 OID 17514)
-- Name: subcategoria subcategoria_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.subcategoria
    ADD CONSTRAINT subcategoria_pkey PRIMARY KEY (idsubcat);


--
-- TOC entry 4900 (class 2606 OID 17480)
-- Name: ticket_data ticket_data_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_data
    ADD CONSTRAINT ticket_data_pkey PRIMARY KEY (idticket);


--
-- TOC entry 4904 (class 2606 OID 17499)
-- Name: ticket_log ticket_log_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_log
    ADD CONSTRAINT ticket_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4902 (class 2606 OID 17490)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (iduser);


--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA rh; Type: ACL; Schema: -; Owner: dbo
--

GRANT USAGE ON SCHEMA rh TO "TICKETSAPP";
GRANT USAGE ON SCHEMA rh TO "RH";


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA tickets; Type: ACL; Schema: -; Owner: dbo
--

GRANT USAGE ON SCHEMA tickets TO "TICKETSAPP";


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE departaments; Type: ACL; Schema: rh; Owner: RH
--

GRANT SELECT ON TABLE rh.departaments TO "TICKETSAPP";


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE roles; Type: ACL; Schema: rh; Owner: RH
--

GRANT SELECT ON TABLE rh.roles TO "TICKETSAPP";


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE users; Type: ACL; Schema: rh; Owner: RH
--

GRANT SELECT,INSERT,UPDATE ON TABLE rh.users TO "TICKETSAPP";


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 238
-- Name: SEQUENCE sec_users; Type: ACL; Schema: rh; Owner: RH
--

GRANT ALL ON SEQUENCE rh.sec_users TO "TICKETSAPP";


-- Completed on 2026-07-02 14:28:04

--
-- PostgreSQL database dump complete
--

\unrestrict tZB4J7eGYIgRy00FXK09qXL4Vd5FfEUtUN2Q1yv5ly4iIW6v6YNJf8VcfGuS4w0

