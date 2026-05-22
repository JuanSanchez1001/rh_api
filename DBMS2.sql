--
-- PostgreSQL database dump
--

\restrict Jy9CHcWhXKmanENcyH06oQO6mdCfELe9miPJjqfKD0CWFYqEUG2DEehuAclWCmZ

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.1

-- Started on 2026-05-22 16:12:19

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 7 (class 2615 OID 16608)
-- Name: rh; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA rh;


ALTER SCHEMA rh OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 16609)
-- Name: tickets; Type: SCHEMA; Schema: -; Owner: TICKETSAPP
--

CREATE SCHEMA tickets;


ALTER SCHEMA tickets OWNER TO "TICKETSAPP";

--
-- TOC entry 313 (class 1255 OID 17213)
-- Name: fn_getausenciabyid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getausenciabyid(v_incidencia integer) RETURNS TABLE(id integer, nombre text, motivo character varying, goceflag integer, vacacionesflag integer, telefono character varying, diasqty integer, fecha_ini date, decha_fin date, autorizaflag integer, voboflag integer, descripcion text, observaciones text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	SELECT
		i.id,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		m.descripcion,
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
	JOIN rh.users u ON(i.useridf = u.nomia)
	WHERE i.id = v_incidencia;
END;
$$;


ALTER FUNCTION public.fn_getausenciabyid(v_incidencia integer) OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 17263)
-- Name: fn_getincidenciabyid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getincidenciabyid(v_id integer) RETURNS TABLE(id integer, nombre text, motivo character varying, goceflag integer, tipoauto integer, placas character varying, lugar character varying, telefono character varying, descripcion text, observaciones text, regresaflag integer, acompanantesqty integer, hora_salida character varying, hora_regreo character varying, diasqty integer, fecha_ini date, fecha_fin date, autorizaflga integer, voboflag integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	SELECT
		d.id,
		concat(u.nombre, ' ', u.ape_paterno, ' ', ape_materno) as nombre,
		m.descripcion as motivo,
		i.goceidf,
		i.tipoautoidf,
		i.placas,
		i.lugar,
		i.telefono,
		i.descripcion,
		i.observaciones,
		i.regresa_flag,
		i.acompanantes_qty,
		i.hora_salida,
		i.hora_regreso,
		i.dias_qty,
		i.fecha_ini,
		i.fecha_fin,
		i.autoriza_flag,
		i.vobo_flag
	FROM rh.incidencia_data d
	JOIN rh.users u ON(d.useridf = u.nomina)
	JOIN rh.motivos m ON(d.motivoidf = m.id)
	WHERE i.id = v_id;
END;
$$;


ALTER FUNCTION public.fn_getincidenciabyid(v_id integer) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 16712)
-- Name: fns_departamentos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fns_departamentos() RETURNS TABLE(v_id_departamento integer, v_description character)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT
			id AS id_departamento,
			description AS description
		FROM public.departamentos_menu;
	END;
$$;


ALTER FUNCTION public.fns_departamentos() OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 16755)
-- Name: fns_menu_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fns_menu_data() RETURNS TABLE(department character varying, json_info json)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
select
	d.description,
	json_arrayagg(
		json_build_object(
			'id', m.id_menu,
			'description', m.descripcion,
			'departamento', d.description,
			'url', url,
			'information', m.large_description,
			'icon', m.media
		) order by m.order
	) AS json_info
from public.menu_data m
join public.departamentos_menu d on(m.department_idf = d.id)
where m.visible = true
group by d.description
;
END;
$$;


ALTER FUNCTION public.fns_menu_data() OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 17227)
-- Name: spd_deleteincidenciabyid(integer, text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.spd_deleteincidenciabyid(IN v_id integer, IN v_comment text, IN v_nomina integer)
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


ALTER PROCEDURE public.spd_deleteincidenciabyid(IN v_id integer, IN v_comment text, IN v_nomina integer) OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 17194)
-- Name: spi_solicitud_ausencia(integer, integer, integer, integer, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.spi_solicitud_ausencia(IN v_nomina integer, IN v_motivo integer, IN v_vacacionesflag integer, IN v_telefono integer, IN v_diasqty integer, IN v_fechaini integer, IN v_fechafin integer, IN v_descripcion text)
    LANGUAGE plpgsql
    AS $$
DECLARE 
today timestamp := to_char(current_timestamp, 'DD/MM/YYYY HH24:MI:SS');
v_incidencia integer;
BEGIN
	INSERT INTO rh.incidencia_data(useridf, motivoidf, vacacionesflag, fecha_creacion,
	telefono, dias_qty, fecha_ini, fecha_fin, descripcion, tipo)
	VALUES (v_nomina, v_motivo, v_vacacionesFlag, today, v_telefono, v_diasQTY, v_fechaIni, v_fechaFin, v_descripcion, 2)
	RETURNING id INTO v_incidencia;
	
	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify, comment)
	VALUES (v_incidencia, today, v_nomina, 'NUEVO');
	COMMIT;
END;
$$;


ALTER PROCEDURE public.spi_solicitud_ausencia(IN v_nomina integer, IN v_motivo integer, IN v_vacacionesflag integer, IN v_telefono integer, IN v_diasqty integer, IN v_fechaini integer, IN v_fechafin integer, IN v_descripcion text) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 17214)
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
-- TOC entry 323 (class 1255 OID 17271)
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
-- TOC entry 314 (class 1255 OID 17246)
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
-- TOC entry 311 (class 1255 OID 17196)
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
-- TOC entry 322 (class 1255 OID 17265)
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
-- TOC entry 320 (class 1255 OID 17256)
-- Name: fn_gettablaausencias(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_gettablaausencias(v_userid integer) RETURNS TABLE(v_id integer, v_nomina integer, v_nombre text, v_fecha text, v_motivo character varying, v_estatus text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		to_char(d.fecha_creacion, 'dd/mm/yyyy'),
		m.descripcion as motivo,
		CASE
			WHEN d.autoriza_flag IS NULL AND vobo_flag IS NULL THEN 'Pendiente voBo y autorizacion'
			WHEN d.autoriza_flag IS NULL AND vobo_flag IS NOT NULL THEN 'Penciente aut'
			WHEN d.vobo_flag IS NULL AND d.autoriza_flag IS NOT NULL THEN 'Penciente VoBo'
		ELSE '' END estatus
		
	FROM rh.incidencia_data d
	JOIN rh.users u ON (d.useridf = u.nomina)
	JOIN rh.motivos m ON (d.motivoidf = m.id)
	WHERE (d.autoriza_flag = 0
	or d.vobo_flag = 0)
	and d.tipo = 2
	and (u.supervior_idf = v_userid or u.rol_idf = 1)
	order by d.fecha_creacion desc
	;
END;
$$;


ALTER FUNCTION rh.fn_gettablaausencias(v_userid integer) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 17257)
-- Name: fn_gettablasalidas(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_gettablasalidas(v_userid integer) RETURNS TABLE(v_id integer, v_nomina integer, v_nombre text, v_fecha text, v_motivo character varying, v_estatus text)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		d.id,
		d.useridf,
		concat(u.nombre, ' ', u.ape_paterno, ' ', u.ape_materno),
		to_char(d.fecha_creacion, 'dd/mm/yyyy'),
		m.descripcion as motivo,
		CASE
			WHEN d.autoriza_flag IS NULL THEN 'Pendiente'
			WHEN d.autoriza_flag = 1 THEN 'Autorizado'
			WHEN d.autoriza_flag = 2 THEN 'Rechazado'
		ELSE '' END AS estatus
	FROM rh.incidencia_data d
	JOIN rh.users u ON (d.useridf = u.nomina)
	JOIN rh.motivos m ON (d.motivoidf = m.id)
	WHERE (d.autoriza_flag is null 
	or d.vobo_flag is null)
	and d.tipo = 1
	and (u.supervior_idf = v_userid or u.rol_idf = 1)
	order by d.fecha_creacion desc
	;
END;
$$;


ALTER FUNCTION rh.fn_gettablasalidas(v_userid integer) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 17207)
-- Name: fn_getusermenu(integer); Type: FUNCTION; Schema: rh; Owner: postgres
--

CREATE FUNCTION rh.fn_getusermenu(v_nomina integer) RETURNS TABLE(title character varying, icon character varying, style text, url text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_departamento integer := (
						select d.id_departamento 
						from rh.users u 
						join rh.departaments d on(u.department_idf=d.id_departamento)
						where u.nomina = v_nomina);
	isLogged integer := CASE v_nomina
							WHEN 0 THEN 0
							ELSE 1
							END;
BEGIN
	IF isLogged = 0 THEN
	RETURN QUERY
		SELECT d.descripcion, d.icon, d.style,d.url
		FROM rh.menu_data d where d.sesionflag = 0;
	ELSE
	RETURN QUERY
		SELECT d.descripcion, d.icon, d.style,d.url
		FROM rh.menu_data d where d.sesionflag <> 0
		AND d.rolidf = CASE 
							WHEN d.rolidf = 0 THEN rolidf
							WHEN v_departamento = 1 THEN rolidf
							ELSE v_departamento
						END;
	END IF;
END;
$$;


ALTER FUNCTION rh.fn_getusermenu(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 17150)
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
JOIN rh.departaments d ON(u.department_idf=id_departamento)
JOIN rh.puestos p ON(u.puesto_idf = p.id)
where u.nomina = v_nomina;
			--v_estatus := 1;
END;
$$;


ALTER FUNCTION rh.fn_login(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 17108)
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
	JOIN rh.users s ON(ts.id = s.nomina)
	WHERE u.nomina = v_nomina;
END;
$$;


ALTER FUNCTION rh.searchuser(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 17228)
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
-- TOC entry 318 (class 1255 OID 17261)
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
-- TOC entry 317 (class 1255 OID 17258)
-- Name: spi_createuser(integer, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spi_createuser(IN v_nomina integer, IN v_nombre character varying, IN v_apepaterno character varying, IN v_apematerno character varying, IN v_genero character varying, IN v_correo character varying, IN v_edad integer, IN v_jefedirecto integer, IN v_rolidf integer, IN v_departament integer, IN v_username character varying, IN v_cargo integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO rh.users(nombre, ape_paterno, ape_materno, genero, correo, edad, supervisor_idf, rol_idf, department_idf, nomina, reset, username, puesto_idf)
	VALUES(v_nombre, v_apePaterno, v_apeMaterno, v_genero, v_correo, v_edad, v_jefeDirecto, v_rolidf, v_departament, 1, v_nomina, v_cargo);
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spi_createuser(IN v_nomina integer, IN v_nombre character varying, IN v_apepaterno character varying, IN v_apematerno character varying, IN v_genero character varying, IN v_correo character varying, IN v_edad integer, IN v_jefedirecto integer, IN v_rolidf integer, IN v_departament integer, IN v_username character varying, IN v_cargo integer) OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 17231)
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
	VALUES (v_nomina, v_motivo, v_vacacionesFlag, today, v_telefono, v_diasQTY, v_fechaIni, v_fechaFin, v_descripcion, 2,0,0)
	RETURNING id INTO v_incidencia;
	
	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify, comment)
	VALUES (v_incidencia, today, v_nomina, 'NUEVO');
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spi_solicitud_ausencia(IN v_nomina integer, IN v_motivo integer, IN v_vacacionesflag integer, IN v_telefono character varying, IN v_diasqty integer, IN v_fechaini date, IN v_fechafin date, IN v_descripcion text) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 17180)
-- Name: spi_solicitud_salida(integer, integer, character varying, integer, integer, character varying, integer, character varying, character varying, text, text, integer, integer, integer, integer, integer); Type: PROCEDURE; Schema: rh; Owner: postgres
--

CREATE PROCEDURE rh.spi_solicitud_salida(IN v_nomina integer, IN v_auto integer, IN v_placas character varying, IN v_motivo integer, IN acompananatesqty integer, IN v_tel character varying, IN regresaflag integer, IN v_salida character varying, IN v_regreso character varying, IN v_lugar text, IN v_descripcion text, IN v_acompanante1 integer, IN v_acompanante2 integer, IN v_acompanante3 integer, IN v_acompanante4 integer, IN v_acompanante5 integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
today timestamp := to_char(current_timestamp, 'DD-MM-YYYY HH24:MI:SS');
v_incidencia integer;
array_acompanantes integer[] := ARRAY[v_acompanante1,v_acompanante2,v_acompanante3,v_acompanante4,v_acompanante5];
acomp integer;

BEGIN

	INSERT INTO rh.incidencia_data(useridf, motivoidf, tipoautoidf, placas, lugar, telefono, hora_salida,
	hora_regreso, descripcion, regresa_flag, acompanantes_qty, fecha_creacion, tipo, autoriza_flag)
	VALUES (v_nomina, v_motivo, v_auto, v_placas, v_lugar, v_tel, v_salida, v_regreso, v_descripcion, 
	regresaflag, acompananatesqty, today, 1, 0)
	--set variable
	RETURNING id INTO v_incidencia;
	
	INSERT INTO rh.incidencia_log(incidenciaidf, fecha, user_modify, comment)
	VALUES(v_incidencia, today, v_nomina, 'NUEVO');

		FOREACH acomp IN ARRAY array_acompanantes LOOP
			IF acomp > 0 THEN
				INSERT INTO rh.acompanantes(incidenciai_df, nomina) VALUES (v_incidencia, acomp);
			END IF;
		END LOOP;
	COMMIT;
END;
$$;


ALTER PROCEDURE rh.spi_solicitud_salida(IN v_nomina integer, IN v_auto integer, IN v_placas character varying, IN v_motivo integer, IN acompananatesqty integer, IN v_tel character varying, IN regresaflag integer, IN v_salida character varying, IN v_regreso character varying, IN v_lugar text, IN v_descripcion text, IN v_acompanante1 integer, IN v_acompanante2 integer, IN v_acompanante3 integer, IN v_acompanante4 integer, IN v_acompanante5 integer) OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 17149)
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
-- TOC entry 316 (class 1255 OID 17260)
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
-- TOC entry 290 (class 1255 OID 17223)
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
-- TOC entry 264 (class 1255 OID 16883)
-- Name: spu_update_password(integer, character); Type: PROCEDURE; Schema: rh; Owner: RH
--

CREATE PROCEDURE rh.spu_update_password(IN v_nomina integer, IN v_password character)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE rh.users 
		SET hash_pass = v_password,
		reset = 0
	where nomina = v_nomina;
END;
$$;


ALTER PROCEDURE rh.spu_update_password(IN v_nomina integer, IN v_password character) OWNER TO "RH";

--
-- TOC entry 300 (class 1255 OID 17224)
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
-- TOC entry 293 (class 1255 OID 17036)
-- Name: fn_cat_afectacion(); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_cat_afectacion() RETURNS TABLE(o_id integer, o_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	id as id,
	descripcion
FROM tickets.cat_afectacion
ORDER BY id;
END;
$$;


ALTER FUNCTION tickets.fn_cat_afectacion() OWNER TO "TICKETSAPP";

--
-- TOC entry 284 (class 1255 OID 16990)
-- Name: fn_cat_prioridad(); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_cat_prioridad() RETURNS TABLE(o_id integer, o_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	id as id,
	descripcion
FROM tickets.cat_prioridad
ORDER BY id;
END;
$$;


ALTER FUNCTION tickets.fn_cat_prioridad() OWNER TO "TICKETSAPP";

--
-- TOC entry 279 (class 1255 OID 16945)
-- Name: fn_categorias(); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_categorias() RETURNS TABLE(o_id_categoria integer, o_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT
		id_categoria,
		descripcion
	FROM tickets.categorias
	WHERE visible = true
	;
END;
$$;


ALTER FUNCTION tickets.fn_categorias() OWNER TO "TICKETSAPP";

--
-- TOC entry 280 (class 1255 OID 16949)
-- Name: fn_fallos(integer); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_fallos(v_id_subcategoria integer) RETURNS TABLE(o_id_fallo integer, o_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT
		id_fallo,
		description
	FROM tickets.fallos
	WHERE idf_subcat = v_id_subcategoria AND visible = true
	;
END;
$$;


ALTER FUNCTION tickets.fn_fallos(v_id_subcategoria integer) OWNER TO "TICKETSAPP";

--
-- TOC entry 304 (class 1255 OID 17007)
-- Name: fn_getalltickets(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getalltickets(v_nomina integer) RETURNS TABLE(id integer, nomina integer, nombre character varying, titulo character varying, afectacion character varying, prioridad character varying, estatus character varying, fecha_creacion text, responsable character varying, button integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
isAdmin integer := (select idf_rol from tickets.users u where u.nomina = v_nomina);
BEGIN

RETURN QUERY
SELECT 

	td.id_ticket as ID,
	u.nomina AS nomia,
	u.nombre AS nombre,
	td.title AS titulo,
	--td.descripcion,
	ca.descripcion AS afectacion,
	cp.descripcion AS prioridad,
	e.descripcion AS estatus,
	to_char(td.fecha_creacion, 'DD/MM/YYYY') AS fecha_creacion,
	COALESCE(u1.nombre, 'Sin asignar') AS responsable,
	CASE isAdmin
		WHEN 1 THEN 1
		ELSE 0
	END AS button
	
FROM tickets.ticket_data td
JOIN rh.users u ON (td.idf_user = u.nomina)
JOIN tickets.cat_prioridad cp ON (td.idf_prioridad = cp.id)
JOIN tickets.cat_afectacion ca ON (td.idf_afectacion = ca.id)
JOIN tickets.estatus e ON (td.idf_estatus = e.id_estatus)
LEFT JOIN tickets.users tu ON (td.idf_responsable = tu.id_user)
LEFT JOIN rh.users u1 ON (tu.nomina = u1.nomina)

WHERE (e.id_estatus = 1 OR e.id_estatus = 2 OR e.id_estatus = 3) 
AND td.idf_user = ( --Se asegura si es admin muestra todos los tickets sino solo los del usuario
	CASE isAdmin
		WHEN 1 THEN td.idf_user
		ELSE V_NOMINA
	END
)
ORDER BY td.id_ticket desc
;
END;
$$;


ALTER FUNCTION tickets.fn_getalltickets(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 17070)
-- Name: fn_getdepartamentos(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getdepartamentos() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT 
	id_departamento AS id,
	departamento
	FROM rh.departaments
	WHERE visible is true;
END;
$$;


ALTER FUNCTION tickets.fn_getdepartamentos() OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 17019)
-- Name: fn_getestatus(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getestatus() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT e.id_estatus, e.descripcion FROM tickets.estatus e where visible = true;
END;
$$;


ALTER FUNCTION tickets.fn_getestatus() OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 17034)
-- Name: fn_getmainmenu(integer, boolean); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getmainmenu(v_nomina integer, v_islogged boolean) RETURNS TABLE(o_url character varying, o_title character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	--isAdmin integer := (select 1 )
BEGIN
IF v_isLogged is false THEN
RETURN QUERY
	SELECT 
		url AS url,
		title AS title
	FROM tickets.main_menu 
	WHERE session is false and visible = 1
	ORDER BY orden
	;
ELSE
RETURN QUERY
	SELECT
		url AS url,
		title AS title
	FROM tickets.users u
	JOIN tickets.roles r ON (u.idf_rol = r.id_rol)
	JOIN tickets.main_menu m ON (u.idf_rol = m.rol_idf)
	WHERE u.idf_rol = m.rol_idf and u.nomina = v_nomina and m.visible = 1 and session is true
	ORDER BY m.orden
	;
END IF;
END;
$$;


ALTER FUNCTION tickets.fn_getmainmenu(v_nomina integer, v_islogged boolean) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 17072)
-- Name: fn_getpuestos(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getpuestos() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT 
	rolid AS id,
	description
	FROM rh.roles
	WHERE visible = 1;
END;
$$;


ALTER FUNCTION tickets.fn_getpuestos() OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 17071)
-- Name: fn_getroles(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getroles() RETURNS TABLE(id integer, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT 
	id_rol AS id,
	description
	FROM tickets.roles
	WHERE visible is true;
END;
$$;


ALTER FUNCTION tickets.fn_getroles() OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 17021)
-- Name: fn_gettechnicalusers(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_gettechnicalusers() RETURNS TABLE(id integer, username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	SELECT
		u.id_user,
		ru.username
	FROM tickets.users u
	JOIN rh.users ru ON (u.nomina = ru.nomina)
	WHERE u.technical = true;
END;
$$;


ALTER FUNCTION tickets.fn_gettechnicalusers() OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 17058)
-- Name: fn_getticketbyid(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getticketbyid(v_id_ticket integer) RETURNS TABLE(title character varying, nomina integer, nombre text, responsable character varying, categoria character varying, subcategoria character varying, fallo character varying, afectacion character varying, prioridad character varying, descripcion text, comentario character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
WITH table_comments AS(
	SELECT 
		tl1.idf_ticket,
		tl1.comentario
	FROM tickets.ticket_log tl1
	WHERE tl1.idf_ticket = v_id_ticket
	LIMIT 1
)
SELECT
	td.title AS title,
	rh.nomina AS nomina,
	concat(rh.nombre, ' ', rh.ape_paterno) AS nombre,
	rh1.username AS responsable,
	c.descripcion AS categoria,
	sc.descripcion AS subcategoria,
	f.description AS fallo,
	a.descripcion AS afectacion,
	p.descripcion AS prioridad,
	td.descripcion AS descripcion,
	tc.comentario AS comentario
FROM tickets.ticket_data td
LEFT JOIN tickets.users u ON(td.idf_responsable = u.id_user)
LEFT JOIN rh.users rh ON(td.idf_user = rh.nomina)
LEFT JOIN rh.users rh1 ON(u.nomina = rh1.nomina)
LEFT JOIN tickets.categorias c ON (td.idf_categoria = c.id_categoria)
LEFT JOIN tickets.subcategoria sc ON(td.idf_subcategoria = sc.id_subcategoria)
LEFT JOIN tickets.fallos f ON(td.idf_fallo = f.id_fallo)
LEFT JOIN tickets.cat_afectacion a ON(td.idf_afectacion = a.id)
LEFT JOIN tickets.cat_prioridad p ON(td.idf_prioridad = p.id)
LEFT JOIN table_comments tc ON(td.id_ticket = tc.idf_ticket)
WHERE td.id_ticket = v_id_ticket
;
END;
$$;


ALTER FUNCTION tickets.fn_getticketbyid(v_id_ticket integer) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 17069)
-- Name: fn_getusers(); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_getusers() RETURNS TABLE(id_user integer, nomina integer, nombre text, username character varying, correo character varying, rol character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
	u.id_user,
	u.nomina,
	concat(rh.nombre, ' ', rh.ape_paterno, ' ', rh.ape_materno) AS nombre,
	rh.username,
	rh.correo,
	r.description AS rol
FROM tickets.users u
JOIN rh.users rh ON (u.nomina = rh.nomina)
JOIN tickets.roles r ON(u.idf_rol = r.id_rol);
END;
$$;


ALTER FUNCTION tickets.fn_getusers() OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 17052)
-- Name: fn_login(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.fn_login(v_nomina integer) RETURNS TABLE(nomina integer, hash text, username character varying, nombre text, departamento character varying, rol character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
--Validaciones del login
RETURN QUERY
select  
	u.nomina,
	rh.hash_pass,
	rh.username,
	concat(rh.nombre, ' ', rh.ape_paterno, ' ', rh.ape_materno) AS nombre,
	rd.departamento,
	r.description
from tickets.users u
join tickets.roles r ON (u.idf_rol = r.id_rol)
join rh.users rh ON (u.nomina = rh.nomina)
join rh.departaments rd ON (rh.department_idf = rd.id_departamento)
where u.nomina = v_nomina;
			--v_estatus := 1;
END;
$$;


ALTER FUNCTION tickets.fn_login(v_nomina integer) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 16910)
-- Name: fn_search_user(integer); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_search_user(v_nomina integer) RETURNS TABLE(o_nomina integer, o_nombre text, o_departamento character varying, o_email character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN
RETURN QUERY
	SELECT
		tu.nomina AS nomina,
		ru.nombre || ' ' || ru.ape_paterno || ' ' || ape_materno AS nombre,
		rd.departamento AS departamento,
		ru.correo AS email
	FROM tickets.users tu
	JOIN rh.users ru ON (tu.nomina = ru.nomina)
	JOIN rh.departaments rd ON  (ru.department_idf = rd.id_departamento)
	WHERE tu.nomina = v_nomina;
END;
$$;


ALTER FUNCTION tickets.fn_search_user(v_nomina integer) OWNER TO "TICKETSAPP";

--
-- TOC entry 282 (class 1255 OID 16946)
-- Name: fn_subcategorias(integer); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_subcategorias(v_id_categoria integer) RETURNS TABLE(o_id_subcategoria integer, o_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT
		id_subcategoria,
		descripcion
	FROM tickets.subcategoria
	WHERE idf_categoria = v_id_categoria AND visible = true
	;
END;
$$;


ALTER FUNCTION tickets.fn_subcategorias(v_id_categoria integer) OWNER TO "TICKETSAPP";

--
-- TOC entry 281 (class 1255 OID 16950)
-- Name: fn_subcategorias(character varying); Type: FUNCTION; Schema: tickets; Owner: TICKETSAPP
--

CREATE FUNCTION tickets.fn_subcategorias(v_id_categoria character varying) RETURNS TABLE(o_id_subcategoria integer, o_descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT
		id_subcategoria,
		descripcion
	FROM tickets.subcategoria
	WHERE idf_categoria = CAST(v_id_categoria AS INTEGER) AND visible = true
	;
END;
$$;


ALTER FUNCTION tickets.fn_subcategorias(v_id_categoria character varying) OWNER TO "TICKETSAPP";

--
-- TOC entry 289 (class 1255 OID 17078)
-- Name: getuserbyid(integer); Type: FUNCTION; Schema: tickets; Owner: postgres
--

CREATE FUNCTION tickets.getuserbyid(v_userid integer) RETURNS TABLE(nomina integer, username character varying, nombre character varying, ape_paterno character varying, ape_materno character varying, correo character varying, rolid integer, puestoid integer, departamentoid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT 
	u.nomina,
	rh.username,
	rh.nombre,
	rh.ape_paterno,
	rh.ape_materno,
	rh.correo,
	r.id_rol AS rol,
	rr.rolid AS puesto,
	rd.id_departamento AS departamento
FROM tickets.users u
LEFT JOIN rh.users rh ON (u.nomina = rh.nomina)
LEFT JOIN tickets.roles r ON (u.idf_rol = r.id_rol)
LEFT JOIN rh.roles rr ON (rh.rol_idf = rr.rolid)
LEFT JOIN rh.departaments rd ON(rh.department_idf = rd.id_departamento)
where u.id_user = v_userid
;
END;
$$;


ALTER FUNCTION tickets.getuserbyid(v_userid integer) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 17068)
-- Name: spd_borrarusuario(integer); Type: PROCEDURE; Schema: tickets; Owner: postgres
--

CREATE PROCEDURE tickets.spd_borrarusuario(IN v_nomina integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
DELETE FROM tickets.users WHERE nomina = v_nomina;
COMMIT;
END;
$$;


ALTER PROCEDURE tickets.spd_borrarusuario(IN v_nomina integer) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 17041)
-- Name: spi_crear_ticket(integer, character varying, integer, integer, integer, integer, text); Type: PROCEDURE; Schema: tickets; Owner: TICKETSAPP
--

CREATE PROCEDURE tickets.spi_crear_ticket(IN v_nomina integer, IN v_title character varying, IN v_categoria integer, IN v_subcategoria integer, IN v_fallo integer, IN v_afectacion integer, IN v_descripcion text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	today timestamp := to_char(current_timestamp, 'DD-MM-YYYY HH24:MI:SS');
BEGIN
	INSERT INTO tickets.ticket_data(idf_user, title, descripcion, idf_categoria, idf_subcategoria, idf_fallo, idf_afectacion, fecha_creacion, idf_estatus)
	VALUES (v_nomina, v_title, v_descripcion, v_categoria, v_subcategoria, v_fallo, v_afectacion, today, 1);
	
	INSERT INTO tickets.ticket_log(idf_ticket, fecha, comentario, idf_estatus)
	VALUES (nextval('tickets.sec_tickets_data'), today, 'NUEVO', 0);
	COMMIT;
END;
$$;


ALTER PROCEDURE tickets.spi_crear_ticket(IN v_nomina integer, IN v_title character varying, IN v_categoria integer, IN v_subcategoria integer, IN v_fallo integer, IN v_afectacion integer, IN v_descripcion text) OWNER TO "TICKETSAPP";

--
-- TOC entry 303 (class 1255 OID 17066)
-- Name: spi_crearusuario(integer, character varying, character varying, character varying, integer, integer, character varying, integer, character varying); Type: PROCEDURE; Schema: tickets; Owner: postgres
--

CREATE PROCEDURE tickets.spi_crearusuario(IN v_nomina integer, IN v_nombre character varying, IN v_ape_paterno character varying, IN v_ape_materno character varying, IN v_idrol integer, IN v_idrol1 integer, IN v_correo character varying, IN v_departamentoid integer, IN v_username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO tickets.users(nomina, idf_rol) VALUES (v_nomina, v_idrol);

INSERT INTO rh.users(nombre, ape_paterno, ape_materno, correo, rol_idf, department_idf, nomina, reset, username)
VALUES (v_nombre, v_ape_paterno, v_ape_materno, v_correo,v_idrol1 ,v_departamentoid, v_nomina, 1,  v_username);
COMMIT;

END;
$$;


ALTER PROCEDURE tickets.spi_crearusuario(IN v_nomina integer, IN v_nombre character varying, IN v_ape_paterno character varying, IN v_ape_materno character varying, IN v_idrol integer, IN v_idrol1 integer, IN v_correo character varying, IN v_departamentoid integer, IN v_username character varying) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 17051)
-- Name: sps_login(integer); Type: PROCEDURE; Schema: tickets; Owner: TICKETSAPP
--

CREATE PROCEDURE tickets.sps_login(IN v_nomina integer, OUT v_estatus integer, OUT v_hash text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_exist integer;
	v_reset integer;
BEGIN
	select count(*) into v_exist from tickets.users where nomina = v_nomina;
	select reset into v_reset
	from tickets.users tu
	join rh.users ru on (tu.nomina = ru.nomina)
	where tu.nomina = v_nomina;
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


ALTER PROCEDURE tickets.sps_login(IN v_nomina integer, OUT v_estatus integer, OUT v_hash text) OWNER TO "TICKETSAPP";

--
-- TOC entry 302 (class 1255 OID 17059)
-- Name: spu_updateticket(integer, integer, integer, integer, integer, character varying); Type: PROCEDURE; Schema: tickets; Owner: TICKETSAPP
--

CREATE PROCEDURE tickets.spu_updateticket(IN v_idticket integer, IN v_id_usermodify integer, IN v_responsible integer, IN v_prioridad integer, IN v_newestatus integer, IN v_comment character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	modifyDAte timestamp := to_char(current_timestamp, 'DD-MM-YYYY HH24:MI:SS');
BEGIN
	UPDATE tickets.ticket_data
		SET 
		fecha_modifica = modifyDAte,
		idf_responsable = v_responsible,
		idf_estatus = v_newestatus,
		idf_prioridad = v_prioridad
		
	WHERE id_ticket = v_idticket;
	--COMMIT;
	INSERT INTO tickets.ticket_log(idf_ticket, fecha, comentario, idf_user_modify, idf_estatus)
	VALUES (v_idticket, modifyDAte, v_comment, v_id_usermodify, v_newestatus);
	COMMIT;
END;
$$;


ALTER PROCEDURE tickets.spu_updateticket(IN v_idticket integer, IN v_id_usermodify integer, IN v_responsible integer, IN v_prioridad integer, IN v_newestatus integer, IN v_comment character varying) OWNER TO "TICKETSAPP";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 16694)
-- Name: departamentos_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departamentos_menu (
    id integer NOT NULL,
    description character varying(50),
    visible integer
);


ALTER TABLE public.departamentos_menu OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16686)
-- Name: menu_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu_data (
    id_menu integer NOT NULL,
    descripcion character varying(40),
    department_idf integer,
    url text,
    media character varying(20),
    "order" integer,
    large_description character varying(100),
    style text,
    visible boolean
);


ALTER TABLE public.menu_data OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16700)
-- Name: sec_dep_menu; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_dep_menu
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE public.sec_dep_menu OWNER TO postgres;

--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 228
-- Name: sec_dep_menu; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_dep_menu OWNED BY public.departamentos_menu.id;


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 228
-- Name: SEQUENCE sec_dep_menu; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON SEQUENCE public.sec_dep_menu IS 'secuence for create departments to main menu';


--
-- TOC entry 229 (class 1259 OID 16701)
-- Name: sec_menu; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_menu
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE public.sec_menu OWNER TO postgres;

--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 229
-- Name: sec_menu; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_menu OWNED BY public.menu_data.id_menu;


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE sec_menu; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON SEQUENCE public.sec_menu IS 'secuence for menu data';


--
-- TOC entry 262 (class 1259 OID 17154)
-- Name: acompanantes; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.acompanantes (
    incidenciai_df integer NOT NULL,
    nomina integer,
    telefono character varying(12)
);


ALTER TABLE rh.acompanantes OWNER TO "RH";

--
-- TOC entry 244 (class 1259 OID 16899)
-- Name: departaments; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.departaments (
    id_departamento integer NOT NULL,
    departamento character varying(50),
    visible boolean
);


ALTER TABLE rh.departaments OWNER TO "RH";

--
-- TOC entry 254 (class 1259 OID 17084)
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
-- TOC entry 255 (class 1259 OID 17089)
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
-- TOC entry 261 (class 1259 OID 17129)
-- Name: incidencias; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.incidencias (
    id integer NOT NULL,
    descripcion character varying(100),
    visible integer
);


ALTER TABLE rh.incidencias OWNER TO "RH";

--
-- TOC entry 263 (class 1259 OID 17197)
-- Name: menu_data; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.menu_data (
    id_menu integer NOT NULL,
    descripcion character varying(100),
    texto text,
    rolidf integer,
    icon character varying(100),
    style text,
    url text,
    sesionflag integer
);


ALTER TABLE rh.menu_data OWNER TO "RH";

--
-- TOC entry 259 (class 1259 OID 17121)
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
-- TOC entry 253 (class 1259 OID 17079)
-- Name: puestos; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.puestos (
    id integer NOT NULL,
    descripcion character varying,
    visible integer
);


ALTER TABLE rh.puestos OWNER TO "RH";

--
-- TOC entry 223 (class 1259 OID 16626)
-- Name: roles; Type: TABLE; Schema: rh; Owner: RH
--

CREATE TABLE rh.roles (
    rolid integer NOT NULL,
    description character varying(50),
    visible numeric(2,0)
);


ALTER TABLE rh.roles OWNER TO "RH";

--
-- TOC entry 245 (class 1259 OID 16905)
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
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 245
-- Name: sec_departamentos; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_departamentos OWNED BY rh.departaments.id_departamento;


--
-- TOC entry 257 (class 1259 OID 17104)
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
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 257
-- Name: sec_incidencias; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_incidencias OWNED BY rh.incidencia_data.id;


--
-- TOC entry 258 (class 1259 OID 17105)
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
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 258
-- Name: sec_incidencias_log; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_incidencias_log OWNED BY rh.incidencia_log.id;


--
-- TOC entry 260 (class 1259 OID 17124)
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
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 260
-- Name: sec_motivos; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_motivos OWNED BY rh.motivos.id;


--
-- TOC entry 256 (class 1259 OID 17102)
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
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 256
-- Name: sec_puestos; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_puestos OWNED BY rh.puestos.id;


--
-- TOC entry 224 (class 1259 OID 16633)
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
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 224
-- Name: sec_roles; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_roles OWNED BY rh.roles.rolid;


--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 224
-- Name: SEQUENCE sec_roles; Type: COMMENT; Schema: rh; Owner: RH
--

COMMENT ON SEQUENCE rh.sec_roles IS 'secuence for roles table';


--
-- TOC entry 222 (class 1259 OID 16621)
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
    department_idf numeric,
    nomina integer,
    reset integer,
    username character varying(20),
    puesto_idf integer,
    admin_level integer
);


ALTER TABLE rh.users OWNER TO "RH";

--
-- TOC entry 225 (class 1259 OID 16644)
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
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 225
-- Name: sec_users; Type: SEQUENCE OWNED BY; Schema: rh; Owner: RH
--

ALTER SEQUENCE rh.sec_users OWNED BY rh.users.user_id;


--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE sec_users; Type: COMMENT; Schema: rh; Owner: RH
--

COMMENT ON SEQUENCE rh.sec_users IS 'secuence for users table';


--
-- TOC entry 249 (class 1259 OID 16976)
-- Name: cat_afectacion; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.cat_afectacion (
    id integer NOT NULL,
    descripcion character varying(100),
    complete_descripcion character varying(300),
    visible integer,
    level_priority integer
);


ALTER TABLE tickets.cat_afectacion OWNER TO "TICKETSAPP";

--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE cat_afectacion; Type: COMMENT; Schema: tickets; Owner: TICKETSAPP
--

COMMENT ON TABLE tickets.cat_afectacion IS 'Catalogo para el tipo de afectacion';


--
-- TOC entry 250 (class 1259 OID 16982)
-- Name: cat_prioridad; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.cat_prioridad (
    id integer NOT NULL,
    descripcion character varying(100),
    complete_desc character varying(300),
    visible boolean
);


ALTER TABLE tickets.cat_prioridad OWNER TO "TICKETSAPP";

--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE cat_prioridad; Type: COMMENT; Schema: tickets; Owner: TICKETSAPP
--

COMMENT ON TABLE tickets.cat_prioridad IS 'Catalogo donde se describe la prioridad del problema';


--
-- TOC entry 232 (class 1259 OID 16768)
-- Name: categorias; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.categorias (
    id_categoria integer NOT NULL,
    descripcion character varying(50),
    visible boolean
);


ALTER TABLE tickets.categorias OWNER TO "TICKETSAPP";

--
-- TOC entry 231 (class 1259 OID 16765)
-- Name: estatus; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.estatus (
    id_estatus integer NOT NULL,
    descripcion character varying(100),
    visible boolean
);


ALTER TABLE tickets.estatus OWNER TO "TICKETSAPP";

--
-- TOC entry 241 (class 1259 OID 16872)
-- Name: fallos; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.fallos (
    id_fallo integer NOT NULL,
    description character varying(100),
    visible boolean,
    idf_subcat integer,
    level_priority integer
);


ALTER TABLE tickets.fallos OWNER TO "TICKETSAPP";

--
-- TOC entry 251 (class 1259 OID 17022)
-- Name: main_menu; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.main_menu (
    id integer NOT NULL,
    title character varying(100),
    url character varying(500),
    descripcion character varying(500),
    visible integer,
    rol_idf integer,
    icon character varying(50),
    session boolean,
    orden integer
);


ALTER TABLE tickets.main_menu OWNER TO "TICKETSAPP";

--
-- TOC entry 239 (class 1259 OID 16864)
-- Name: roles; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.roles (
    id_rol integer NOT NULL,
    description character varying(100),
    visible boolean
);


ALTER TABLE tickets.roles OWNER TO "TICKETSAPP";

--
-- TOC entry 236 (class 1259 OID 16818)
-- Name: sec_categorias; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_categorias
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99
    CACHE 1;


ALTER SEQUENCE tickets.sec_categorias OWNER TO "TICKETSAPP";

--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 236
-- Name: sec_categorias; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_categorias OWNED BY tickets.categorias.id_categoria;


--
-- TOC entry 237 (class 1259 OID 16846)
-- Name: sec_estatus; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_estatus
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99
    CACHE 1;


ALTER SEQUENCE tickets.sec_estatus OWNER TO "TICKETSAPP";

--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 237
-- Name: sec_estatus; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_estatus OWNED BY tickets.estatus.id_estatus;


--
-- TOC entry 242 (class 1259 OID 16879)
-- Name: sec_fallos; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_fallos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_fallos OWNER TO "TICKETSAPP";

--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 242
-- Name: sec_fallos; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_fallos OWNED BY tickets.fallos.id_fallo;


--
-- TOC entry 252 (class 1259 OID 17064)
-- Name: sec_main_menu; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_main_menu
    START WITH 8
    INCREMENT BY 1
    MINVALUE 8
    MAXVALUE 999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_main_menu OWNER TO "TICKETSAPP";

--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 252
-- Name: sec_main_menu; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_main_menu OWNED BY tickets.main_menu.id;


--
-- TOC entry 240 (class 1259 OID 16870)
-- Name: sec_roles; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_roles
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99
    CACHE 1;


ALTER SEQUENCE tickets.sec_roles OWNER TO "TICKETSAPP";

--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 240
-- Name: sec_roles; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_roles OWNED BY tickets.roles.id_rol;


--
-- TOC entry 233 (class 1259 OID 16771)
-- Name: subcategoria; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.subcategoria (
    id_subcategoria integer NOT NULL,
    idf_categoria integer NOT NULL,
    descripcion character varying(500),
    visible boolean
);


ALTER TABLE tickets.subcategoria OWNER TO "TICKETSAPP";

--
-- TOC entry 238 (class 1259 OID 16849)
-- Name: sec_subcategoria; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_subcategoria
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_subcategoria OWNER TO "TICKETSAPP";

--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 238
-- Name: sec_subcategoria; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_subcategoria OWNED BY tickets.subcategoria.id_subcategoria;


--
-- TOC entry 247 (class 1259 OID 16961)
-- Name: ticket_log; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.ticket_log (
    id integer NOT NULL,
    idf_ticket integer,
    fecha timestamp without time zone,
    comentario character varying(200),
    idf_user_modify integer,
    idf_estatus integer
);


ALTER TABLE tickets.ticket_log OWNER TO "TICKETSAPP";

--
-- TOC entry 248 (class 1259 OID 16969)
-- Name: sec_ticket_log; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_ticket_log
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999999999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_ticket_log OWNER TO "TICKETSAPP";

--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 248
-- Name: sec_ticket_log; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_ticket_log OWNED BY tickets.ticket_log.id;


--
-- TOC entry 221 (class 1259 OID 16611)
-- Name: tickets_data; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.tickets_data (
    id_ticket integer NOT NULL,
    nomina_owner integer,
    title character varying(20),
    problem_desc text,
    idf_cat integer,
    idf_subcat integer,
    idf_status integer,
    idf_user integer,
    last_date date,
    creation_date timestamp without time zone,
    idf_prioridad integer,
    idf_type integer,
    idf_fallo integer
);


ALTER TABLE tickets.tickets_data OWNER TO "TICKETSAPP";

--
-- TOC entry 235 (class 1259 OID 16779)
-- Name: sec_tickets_data; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_tickets_data
    START WITH 11000
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_tickets_data OWNER TO "TICKETSAPP";

--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 235
-- Name: sec_tickets_data; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_tickets_data OWNED BY tickets.tickets_data.id_ticket;


--
-- TOC entry 230 (class 1259 OID 16762)
-- Name: users; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.users (
    id_user integer NOT NULL,
    nomina integer,
    idf_rol integer,
    technical boolean
);


ALTER TABLE tickets.users OWNER TO "TICKETSAPP";

--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE users; Type: COMMENT; Schema: tickets; Owner: TICKETSAPP
--

COMMENT ON TABLE tickets.users IS 'Tabla del aplicativo tickets';


--
-- TOC entry 243 (class 1259 OID 16885)
-- Name: sec_users; Type: SEQUENCE; Schema: tickets; Owner: TICKETSAPP
--

CREATE SEQUENCE tickets.sec_users
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1;


ALTER SEQUENCE tickets.sec_users OWNER TO "TICKETSAPP";

--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 243
-- Name: sec_users; Type: SEQUENCE OWNED BY; Schema: tickets; Owner: TICKETSAPP
--

ALTER SEQUENCE tickets.sec_users OWNED BY tickets.users.id_user;


--
-- TOC entry 246 (class 1259 OID 16954)
-- Name: ticket_data; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.ticket_data (
    id_ticket integer DEFAULT nextval('tickets.sec_tickets_data'::regclass) NOT NULL,
    idf_user integer,
    title character varying(20),
    descripcion text,
    idf_categoria integer,
    idf_subcategoria integer,
    idf_fallo integer,
    idf_prioridad integer,
    idf_afectacion integer,
    fecha_creacion timestamp with time zone,
    fecha_modifica timestamp without time zone,
    idf_responsable integer,
    idf_estatus integer
);


ALTER TABLE tickets.ticket_data OWNER TO "TICKETSAPP";

--
-- TOC entry 234 (class 1259 OID 16774)
-- Name: tickets_log; Type: TABLE; Schema: tickets; Owner: TICKETSAPP
--

CREATE TABLE tickets.tickets_log (
    idf_ticket integer,
    fecha timestamp without time zone,
    comment character varying(100),
    idf_user integer,
    idf_status integer
);


ALTER TABLE tickets.tickets_log OWNER TO "TICKETSAPP";

--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE tickets_log; Type: COMMENT; Schema: tickets; Owner: TICKETSAPP
--

COMMENT ON TABLE tickets.tickets_log IS 'log generales para los tickets';


--
-- TOC entry 4871 (class 2604 OID 16702)
-- Name: departamentos_menu id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos_menu ALTER COLUMN id SET DEFAULT nextval('public.sec_dep_menu'::regclass);


--
-- TOC entry 4870 (class 2604 OID 16703)
-- Name: menu_data id_menu; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_data ALTER COLUMN id_menu SET DEFAULT nextval('public.sec_menu'::regclass);


--
-- TOC entry 4878 (class 2604 OID 16907)
-- Name: departaments id_departamento; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.departaments ALTER COLUMN id_departamento SET DEFAULT nextval('rh.sec_departamentos'::regclass);


--
-- TOC entry 4883 (class 2604 OID 17110)
-- Name: incidencia_data id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_data ALTER COLUMN id SET DEFAULT nextval('rh.sec_incidencias'::regclass);


--
-- TOC entry 4884 (class 2604 OID 17111)
-- Name: incidencia_log id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_log ALTER COLUMN id SET DEFAULT nextval('rh.sec_incidencias_log'::regclass);


--
-- TOC entry 4885 (class 2604 OID 17125)
-- Name: motivos id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.motivos ALTER COLUMN id SET DEFAULT nextval('rh.sec_motivos'::regclass);


--
-- TOC entry 4882 (class 2604 OID 17109)
-- Name: puestos id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.puestos ALTER COLUMN id SET DEFAULT nextval('rh.sec_puestos'::regclass);


--
-- TOC entry 4869 (class 2604 OID 16634)
-- Name: roles rolid; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.roles ALTER COLUMN rolid SET DEFAULT nextval('rh.sec_roles'::regclass);


--
-- TOC entry 4868 (class 2604 OID 16645)
-- Name: users user_id; Type: DEFAULT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.users ALTER COLUMN user_id SET DEFAULT nextval('rh.sec_users'::regclass);


--
-- TOC entry 4874 (class 2604 OID 16819)
-- Name: categorias id_categoria; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('tickets.sec_categorias'::regclass);


--
-- TOC entry 4873 (class 2604 OID 16847)
-- Name: estatus id_estatus; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.estatus ALTER COLUMN id_estatus SET DEFAULT nextval('tickets.sec_estatus'::regclass);


--
-- TOC entry 4877 (class 2604 OID 16948)
-- Name: fallos id_fallo; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.fallos ALTER COLUMN id_fallo SET DEFAULT nextval('tickets.sec_fallos'::regclass);


--
-- TOC entry 4881 (class 2604 OID 17065)
-- Name: main_menu id; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.main_menu ALTER COLUMN id SET DEFAULT nextval('tickets.sec_main_menu'::regclass);


--
-- TOC entry 4876 (class 2604 OID 16871)
-- Name: roles id_rol; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.roles ALTER COLUMN id_rol SET DEFAULT nextval('tickets.sec_roles'::regclass);


--
-- TOC entry 4875 (class 2604 OID 16851)
-- Name: subcategoria id_subcategoria; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.subcategoria ALTER COLUMN id_subcategoria SET DEFAULT nextval('tickets.sec_subcategoria'::regclass);


--
-- TOC entry 4880 (class 2604 OID 16970)
-- Name: ticket_log id; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_log ALTER COLUMN id SET DEFAULT nextval('tickets.sec_ticket_log'::regclass);


--
-- TOC entry 4872 (class 2604 OID 16886)
-- Name: users id_user; Type: DEFAULT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.users ALTER COLUMN id_user SET DEFAULT nextval('tickets.sec_users'::regclass);


--
-- TOC entry 5085 (class 0 OID 16694)
-- Dependencies: 227
-- Data for Name: departamentos_menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departamentos_menu (id, description, visible) FROM stdin;
1	Recursos Humanos	1
2	Sistemas (IT)	1
3	Nominas	1
\.


--
-- TOC entry 5084 (class 0 OID 16686)
-- Dependencies: 226
-- Data for Name: menu_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menu_data (id_menu, descripcion, department_idf, url, media, "order", large_description, style, visible) FROM stdin;
1	Viaticos	1	http://192.168.0.12:9050/viaticos/	bi bi-bus-front	1	Portal de viaticos	\N	t
2	Proveedores	3	http://192.168.0.218:8080/proveedoresFeg_v3/auth/login	bi bi-truck	1	Portal de proveedores	\N	t
3	Salas	1	http://192.168.0.13:9100/#/home	bi bi-hdmi	2	Portal de reserva de salas	\N	t
4	Horas Extras	1	http://192.168.0.13:8080/horasExtras/login	bi bi-tencent-qq	3	Portal para registrar horas extras	\N	t
5	Sistema de Tickets	2	http://192.168.0.13:9001	bi bi-tools	1	Sistema de tickets para asistencia tecnica	\N	t
\.


--
-- TOC entry 5120 (class 0 OID 17154)
-- Dependencies: 262
-- Data for Name: acompanantes; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.acompanantes (incidenciai_df, nomina, telefono) FROM stdin;
8	4436	\N
8	4436	\N
9	1234	\N
9	4321	\N
10	4436	\N
10	4321	\N
11	4436	\N
11	4321	\N
12	4436	\N
12	4321	\N
12	44	\N
12	33	\N
12	403	\N
13	4436	\N
13	4321	\N
13	44	\N
13	33	\N
13	403	\N
14	4436	\N
14	4321	\N
14	44	\N
14	33	\N
14	403	\N
15	4436	\N
15	4321	\N
\.


--
-- TOC entry 5102 (class 0 OID 16899)
-- Dependencies: 244
-- Data for Name: departaments; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.departaments (id_departamento, departamento, visible) FROM stdin;
1	Sistemas	t
2	Recursos humanos	t
3	Seguridad e Higiene	t
4	Calidad	t
6	Diseño	t
7	Ensamble	t
5	Calidad	f
\.


--
-- TOC entry 5112 (class 0 OID 17084)
-- Dependencies: 254
-- Data for Name: incidencia_data; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.incidencia_data (id, useridf, motivoidf, goceidf, vacacionesflag, tipoautoidf, placas, lugar, telefono, dias_qty, fecha_ini, fecha_fin, fecha_creacion, autoriza_flag, vobo_flag, descripcion, observaciones, regresa_flag, acompanantes_qty, hora_salida, hora_regreso, tipo) FROM stdin;
2	4436	1	\N	\N	1	OKPX123	Rumbo a queretaro chachau	\N	\N	\N	\N	\N	\N	\N	Prueba de api	\N	1	\N	\N	\N	\N
4	4436	1	\N	\N	1	OKPX133	Rumbo a queretaro chachau	\N	\N	\N	\N	\N	\N	\N	Prueba2 de api	\N	1	\N	\N	\N	\N
5	4436	1	\N	\N	1	OKPX133	Rumbo a queretaro chachau	\N	\N	\N	\N	\N	\N	\N	Prueba2 de api	\N	1	\N	\N	\N	\N
8	4436	1	\N	\N	1	OKPX133	Rumbo a queretaro chachau	\N	\N	\N	\N	\N	\N	\N	Prueba2 de api	\N	1	2	\N	\N	\N
9	4436	1	\N	\N	1	OKPX133	Rumbo a queretaro chachau	\N	\N	\N	\N	\N	\N	\N	Prueba2 de api	\N	1	2	\N	\N	\N
10	1234	1	\N	\N	1	OKPX133	La casa de cachika	\N	\N	\N	\N	\N	\N	\N	Prueba4 de api	\N	1	2	\N	\N	\N
11	1234	1	\N	\N	1	OKPX133	La casa de cachika	\N	\N	\N	\N	\N	\N	\N	Prueba4 de api	\N	1	2	\N	\N	\N
12	401	1	\N	\N	1	UFC123	La casa de cachika	\N	\N	\N	\N	2026-05-14 16:03:13	\N	\N	Prueba de la horai	\N	1	5	\N	\N	\N
13	401	1	\N	\N	1	UFC123	La casa de cachika	\N	\N	\N	\N	2026-05-14 16:07:49	\N	\N	Prueba de la horai	\N	1	5	\N	\N	\N
15	1234	1	\N	\N	1	OKPX133	La casa de cachika	\N	\N	\N	\N	2026-05-14 16:14:12	\N	\N	Prueba4 de api	\N	1	2	7:00	14:00	\N
14	401	1	0	\N	1	UFC123	La casa de cachika	\N	\N	\N	\N	2026-05-14 16:08:59	1	\N	Prueba de la horai	Se realiza modificacion	1	5	\N	\N	\N
18	4436	3	1	0	\N	\N	\N	4428304862	2	2026-05-24	2026-05-26	2026-05-20 10:47:36	1	1	Prueba de vacaciones	Se hace una prueba de update	\N	\N	\N	\N	2
16	4436	3	1	0	2	UPK1392-CCC	xxxxxxx	\N	2	2026-05-24	2026-05-26	2026-05-15 15:26:32	1	1	xxxxxxxx	Prueba para las salidas	0	0	08:30	00:00	1
19	4436	2	\N	\N	1	IKC4VC	Por hay	\N	\N	\N	\N	2026-05-21 12:59:08	\N	\N	Prueba 2	\N	1	0	09:00	14:00	1
20	403	5	\N	1	\N	\N	\N	44123458	8	\N	2026-04-29	2026-05-21 13:02:45	\N	\N	Prueba	\N	\N	\N	\N	\N	2
17	4436	3	2	0	\N	\N	\N	4428304862	2	2026-05-24	2026-05-26	2026-05-20 10:46:02	0	0	Prueba de vacaciones	\N	\N	\N	\N	\N	2
21	4436	5	\N	0	\N	\N	\N	123456711	6	\N	2026-04-28	2026-05-22 13:14:45	0	0	Otra mas	\N	\N	\N	\N	\N	2
\.


--
-- TOC entry 5113 (class 0 OID 17089)
-- Dependencies: 255
-- Data for Name: incidencia_log; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.incidencia_log (id, incidenciaidf, fecha, user_modify, comment) FROM stdin;
1	3	2026-05-14 15:25:16	4436	NUEVO
2	4	2026-05-14 15:31:34	4436	NUEVO
3	5	2026-05-14 15:35:40	4436	NUEVO
6	8	2026-05-14 15:42:30	4436	NUEVO
7	9	2026-05-14 15:54:24	4436	NUEVO
8	10	2026-05-14 15:55:23	1234	NUEVO
9	11	2026-05-14 15:59:03	1234	NUEVO
10	12	2026-05-14 16:03:13	401	NUEVO
11	13	2026-05-14 16:07:49	401	NUEVO
12	14	2026-05-14 16:08:59	401	NUEVO
13	15	2026-05-14 16:14:12	1234	NUEVO
14	16	2026-05-15 15:26:32	4436	NUEVO
15	16	2026-05-18 15:22:31	4436	Se autorizan vacaciones
16	16	2026-05-18 15:25:06	4431	Se realiza modificacion
17	17	2026-05-20 10:46:02	4436	NUEVO
18	18	2026-05-20 10:47:36	4436	NUEVO
19	18	2026-05-21 08:12:50	401	Se hace una prueba de update
20	16	2026-05-21 08:21:59	401	Se hace una prueba de update
21	16	2026-05-21 08:28:21	404	Prueba para las salidas
22	19	2026-05-21 12:59:08	4436	NUEVO
23	20	2026-05-21 13:02:45	403	NUEVO
24	17	2026-05-22 12:56:58	4436	\N
25	17	2026-05-22 12:57:47	4436	\N
26	17	2026-05-22 13:04:15	4436	\N
27	17	2026-05-22 13:04:33	4436	\N
28	17	2026-05-22 13:09:21	4436	\N
29	21	2026-05-22 13:14:45	4436	NUEVO
\.


--
-- TOC entry 5119 (class 0 OID 17129)
-- Dependencies: 261
-- Data for Name: incidencias; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.incidencias (id, descripcion, visible) FROM stdin;
2	Salida	1
1	Ausencia	1
\.


--
-- TOC entry 5121 (class 0 OID 17197)
-- Dependencies: 263
-- Data for Name: menu_data; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.menu_data (id_menu, descripcion, texto, rolidf, icon, style, url, sesionflag) FROM stdin;
3	Reporte	Modulo para RH, genera reportes	2	\N	\N	\N	1
6	Login	Login	\N	\N	\N	\N	0
5	Usuarios	Modulo para dar de alta o modificar usuarios	2	\N	\N	\N	1
2	Cerrar Sesion	Es el logout, visible cuando se inicia sesion	0	\N	\N	\N	1
4	Salidas	Es la tabla para los vigilantes. Ven todas las inciedncias de salida	0	\N	\N	\N	1
1	Inicio	Este modulo es el inicio y es para todos, todos lo pueden ver	0	\N	\N	/rh	0
7	Incidencias	\N	2	\N	\N	/rh/incidencias	1
\.


--
-- TOC entry 5117 (class 0 OID 17121)
-- Dependencies: 259
-- Data for Name: motivos; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.motivos (id, descripcion, tipoincidenciaidf, visible) FROM stdin;
1	Enfermedad	1	1
2	Laboral	2	1
3	Personal	2	1
4	Luto	1	1
5	Matrimonio	1	1
6	Nacimiento de hijo	1	1
\.


--
-- TOC entry 5111 (class 0 OID 17079)
-- Dependencies: 253
-- Data for Name: puestos; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.puestos (id, descripcion, visible) FROM stdin;
1	Subordinado	1
2	Oprador	1
3	Director	1
4	Tecnico	1
5	Gerente	1
6	Coordinador	1
7	Ingeniero	1
8	Supervisor	1
\.


--
-- TOC entry 5081 (class 0 OID 16626)
-- Dependencies: 223
-- Data for Name: roles; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.roles (rolid, description, visible) FROM stdin;
2	Administrador	1
3	Directivo	1
4	Gerente	1
5	Tecnico	1
6	Ingeniero	1
7	Practicante	1
8	Coordinador	1
\.


--
-- TOC entry 5080 (class 0 OID 16621)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: rh; Owner: RH
--

COPY rh.users (user_id, nombre, ape_paterno, ape_materno, genero, correo, edad, supervior_idf, rol_idf, hash_pass, department_idf, nomina, reset, username, puesto_idf, admin_level) FROM stdin;
6	Juan Pablo	Sanchez	Perez	M	prueba@gmail.com	25	401	1	$2b$10$k2scQD8UHSB4h7DuYIqzKubozfjZjBcAVNF2pBhHiDgkJCSTKn3YK	1	4436	0	sanch0d	1	0
7	Aristides	Camacho	\N	M	a-camacho@fegq.com.mx	\N	\N	0	$2b$10$k2scQD8UHSB4h7DuYIqzKubozfjZjBcAVNF2pBhHiDgkJCSTKn3YK	2	404	0	acamacho	\N	\N
8	Jose Manuel	Paez	Ocampo	M	j-paez@fegq.com.mx	\N	404	0	$2b$10$k2scQD8UHSB4h7DuYIqzKubozfjZjBcAVNF2pBhHiDgkJCSTKn3YK	3	403	0	jpaez	\N	\N
9	Erendira	Rendon	\N	F	e-rendon@fegq.com.mx	\N	404	1	$2b$10$k2scQD8UHSB4h7DuYIqzKubozfjZjBcAVNF2pBhHiDgkJCSTKn3YK	2	402	0	erondon	\N	0
10	Ramiro	Espino	\N	M	r-espino@fegq.com.mx	\N	404	1	$2b$10$k2scQD8UHSB4h7DuYIqzKubozfjZjBcAVNF2pBhHiDgkJCSTKn3YK	1	401	0	framiro	\N	0
\.


--
-- TOC entry 5107 (class 0 OID 16976)
-- Dependencies: 249
-- Data for Name: cat_afectacion; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.cat_afectacion (id, descripcion, complete_descripcion, visible, level_priority) FROM stdin;
4	No puedo trabajar	\N	1	\N
3	Trabajo con dificultad	\N	1	\N
2	El departamento no puede trabajar	\N	1	\N
1	Puedo trabajar	\N	1	\N
\.


--
-- TOC entry 5108 (class 0 OID 16982)
-- Dependencies: 250
-- Data for Name: cat_prioridad; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.cat_prioridad (id, descripcion, complete_desc, visible) FROM stdin;
3	Baja	\N	t
2	Media	\N	t
1	Alta	\N	t
\.


--
-- TOC entry 5090 (class 0 OID 16768)
-- Dependencies: 232
-- Data for Name: categorias; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.categorias (id_categoria, descripcion, visible) FROM stdin;
1	t	f
2	Hardware	t
3	Software	t
\.


--
-- TOC entry 5089 (class 0 OID 16765)
-- Dependencies: 231
-- Data for Name: estatus; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.estatus (id_estatus, descripcion, visible) FROM stdin;
1	Nuevo	t
2	Asignado	t
3	En curso	t
4	Terminado	t
\.


--
-- TOC entry 5099 (class 0 OID 16872)
-- Dependencies: 241
-- Data for Name: fallos; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.fallos (id_fallo, description, visible, idf_subcat, level_priority) FROM stdin;
1	No abre	t	1	\N
2	Sin licencia	t	1	\N
3	Instalación de impresora	t	2	\N
4	No puedo imprimir	t	2	\N
5	Instalar software	t	3	\N
6	Carga de precios	t	3	\N
7	Falla Ethernet	t	4	\N
8	Sin internet	t	4	\N
\.


--
-- TOC entry 5109 (class 0 OID 17022)
-- Dependencies: 251
-- Data for Name: main_menu; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.main_menu (id, title, url, descripcion, visible, rol_idf, icon, session, orden) FROM stdin;
1	Login	/tickets/login	Pagina de logueo de tickets	1	1	\N	f	1
3	Tickets	/tickets/table/ver_tickets	Ver mis info de mis tickets	1	1	\N	t	3
4	Reportes	\N	Reporteria de tickets	0	1	\N	t	4
5	Logs	\N	Ver informacion de un ticket	0	1	\N	t	5
7	Administrador	\N	Gestionar	0	1	\N	t	7
6	Logout	/tickets/logout	Salir de tickets	1	1	\N	t	6
2	Crear Ticket	/tickets	Inicio	1	1	\N	f	2
8	Crear Ticket	/tickets	Crear un nuevo ticket con login	1	1	\N	t	\N
\.


--
-- TOC entry 5097 (class 0 OID 16864)
-- Dependencies: 239
-- Data for Name: roles; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.roles (id_rol, description, visible) FROM stdin;
1	Help desk	t
2	Administrador	t
3	Usuario	t
4	Prueba	f
\.


--
-- TOC entry 5091 (class 0 OID 16771)
-- Dependencies: 233
-- Data for Name: subcategoria; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.subcategoria (id_subcategoria, idf_categoria, descripcion, visible) FROM stdin;
1	2	Office 365	\N
2	2	Problemas de impresion	t
3	3	Epicor	t
4	2	Problemas de red	t
\.


--
-- TOC entry 5104 (class 0 OID 16954)
-- Dependencies: 246
-- Data for Name: ticket_data; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.ticket_data (id_ticket, idf_user, title, descripcion, idf_categoria, idf_subcategoria, idf_fallo, idf_prioridad, idf_afectacion, fecha_creacion, fecha_modifica, idf_responsable, idf_estatus) FROM stdin;
11001	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:47:05-06	\N	\N	1
11009	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:50:39-06	\N	\N	1
11011	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:50:40-06	\N	\N	1
11014	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:03-06	\N	\N	1
11016	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:04-06	\N	\N	1
11018	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:04-06	\N	\N	1
11021	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:21-06	\N	\N	1
11023	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:22-06	\N	\N	1
11025	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:23-06	\N	\N	1
11027	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:51:23-06	\N	\N	1
11032	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:56:19-06	\N	\N	1
11033	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:56:20-06	\N	\N	1
11034	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:56:20-06	\N	\N	1
11035	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:56:21-06	\N	\N	1
11037	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:57:06-06	\N	\N	1
11038	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:58:06-06	\N	\N	1
11039	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:58:07-06	\N	\N	1
11040	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:58:09-06	\N	\N	1
11041	4436	prueba web	prueba	3	3	5	1	1	2026-04-23 11:14:07-06	\N	\N	1
11043	1	prueba 3	prueba 3 para la carga de tickets	2	2	3	1	1	2026-04-23 11:36:21-06	\N	\N	1
11044	4436	Prueba para logs	Pruba para ver si se inserta en logs ñññ	2	2	3	1	1	2026-04-23 11:43:15-06	\N	\N	1
11004	1	Prueba	Esto es una prueba	1	1	1	1	1	2026-04-22 12:48:57-06	2026-05-04 15:12:48	1	3
11046	403	prueba nuevo diseño	Este es una prueba para ver el nuevo diseño de mi aplicacion de tickets.\nYa acepta una longitud indefinida para la poderosa descripcion. A ver si cierto :( que no quiero rehacer mi tablita	2	2	3	\N	1	2026-05-07 12:28:56-06	\N	\N	1
11042	4436	Titulo	prueba	2	2	3	2	1	2026-04-23 11:31:31-06	2026-05-08 10:22:17	1	2
\.


--
-- TOC entry 5105 (class 0 OID 16961)
-- Dependencies: 247
-- Data for Name: ticket_log; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.ticket_log (id, idf_ticket, fecha, comentario, idf_user_modify, idf_estatus) FROM stdin;
13	11041	2026-04-12 00:00:00	Otra pruebita mas	1	3
14	11044	2026-04-10 00:00:00	Se realiza una prueba	1	2
15	11004	2026-05-04 15:10:42	Esta es otra prueba para comprobar que funcione bien	4436	3
16	11004	2026-05-04 15:12:48	Esta es otra prueba para comprobar que funcione bien	4436	3
17	11047	2026-05-07 12:28:56	NUEVO	\N	0
18	11042	2026-05-08 10:22:17	Una prueba desde el front	4436	2
\.


--
-- TOC entry 5079 (class 0 OID 16611)
-- Dependencies: 221
-- Data for Name: tickets_data; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.tickets_data (id_ticket, nomina_owner, title, problem_desc, idf_cat, idf_subcat, idf_status, idf_user, last_date, creation_date, idf_prioridad, idf_type, idf_fallo) FROM stdin;
12	4436	prueba1	registro de prueba	1	2	1	\N	\N	2026-04-17 09:29:54.835933	\N	\N	\N
13	4436	prueba1	registro de prueba	1	2	1	\N	\N	2026-04-17 09:30:40	\N	\N	\N
\.


--
-- TOC entry 5092 (class 0 OID 16774)
-- Dependencies: 234
-- Data for Name: tickets_log; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.tickets_log (idf_ticket, fecha, comment, idf_user, idf_status) FROM stdin;
\.


--
-- TOC entry 5088 (class 0 OID 16762)
-- Dependencies: 230
-- Data for Name: users; Type: TABLE DATA; Schema: tickets; Owner: TICKETSAPP
--

COPY tickets.users (id_user, nomina, idf_rol, technical) FROM stdin;
1	4436	1	t
2	403	3	f
5	404	3	f
3	402	3	f
4	401	2	t
\.


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 228
-- Name: sec_dep_menu; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_dep_menu', 3, true);


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 229
-- Name: sec_menu; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_menu', 13, true);


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 245
-- Name: sec_departamentos; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_departamentos', 7, true);


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 257
-- Name: sec_incidencias; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_incidencias', 21, true);


--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 258
-- Name: sec_incidencias_log; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_incidencias_log', 29, true);


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 260
-- Name: sec_motivos; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_motivos', 6, true);


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 256
-- Name: sec_puestos; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_puestos', 8, true);


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 224
-- Name: sec_roles; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_roles', 8, true);


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 225
-- Name: sec_users; Type: SEQUENCE SET; Schema: rh; Owner: RH
--

SELECT pg_catalog.setval('rh.sec_users', 10, true);


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 236
-- Name: sec_categorias; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_categorias', 3, true);


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 237
-- Name: sec_estatus; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_estatus', 4, true);


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 242
-- Name: sec_fallos; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_fallos', 8, true);


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 252
-- Name: sec_main_menu; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_main_menu', 8, false);


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 240
-- Name: sec_roles; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_roles', 4, true);


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 238
-- Name: sec_subcategoria; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_subcategoria', 4, true);


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 248
-- Name: sec_ticket_log; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_ticket_log', 18, true);


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 235
-- Name: sec_tickets_data; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_tickets_data', 11047, true);


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 243
-- Name: sec_users; Type: SEQUENCE SET; Schema: tickets; Owner: TICKETSAPP
--

SELECT pg_catalog.setval('tickets.sec_users', 5, true);


--
-- TOC entry 4895 (class 2606 OID 16699)
-- Name: departamentos_menu departamentos_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos_menu
    ADD CONSTRAINT departamentos_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 4893 (class 2606 OID 16693)
-- Name: menu_data menu_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_data
    ADD CONSTRAINT menu_data_pkey PRIMARY KEY (id_menu);


--
-- TOC entry 4909 (class 2606 OID 16904)
-- Name: departaments departaments_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.departaments
    ADD CONSTRAINT departaments_pkey PRIMARY KEY (id_departamento);


--
-- TOC entry 4923 (class 2606 OID 17097)
-- Name: incidencia_data incidencia_data_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_data
    ADD CONSTRAINT incidencia_data_pkey PRIMARY KEY (id);


--
-- TOC entry 4925 (class 2606 OID 17100)
-- Name: incidencia_log incidencia_log_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencia_log
    ADD CONSTRAINT incidencia_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4929 (class 2606 OID 17134)
-- Name: incidencias incidencias_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.incidencias
    ADD CONSTRAINT incidencias_pkey PRIMARY KEY (id);


--
-- TOC entry 4931 (class 2606 OID 17204)
-- Name: menu_data menu_data_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.menu_data
    ADD CONSTRAINT menu_data_pkey PRIMARY KEY (id_menu);


--
-- TOC entry 4927 (class 2606 OID 17128)
-- Name: motivos motivos_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.motivos
    ADD CONSTRAINT motivos_pkey PRIMARY KEY (id);


--
-- TOC entry 4921 (class 2606 OID 17094)
-- Name: puestos puestos_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.puestos
    ADD CONSTRAINT puestos_pkey PRIMARY KEY (id);


--
-- TOC entry 4891 (class 2606 OID 16640)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rolid);


--
-- TOC entry 4889 (class 2606 OID 16643)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: rh; Owner: RH
--

ALTER TABLE ONLY rh.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4915 (class 2606 OID 16981)
-- Name: cat_afectacion cat_afectacion_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.cat_afectacion
    ADD CONSTRAINT cat_afectacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4917 (class 2606 OID 16987)
-- Name: cat_prioridad cat_prioridad_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.cat_prioridad
    ADD CONSTRAINT cat_prioridad_pkey PRIMARY KEY (id);


--
-- TOC entry 4901 (class 2606 OID 16807)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- TOC entry 4899 (class 2606 OID 16810)
-- Name: estatus estatus_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.estatus
    ADD CONSTRAINT estatus_pkey PRIMARY KEY (id_estatus);


--
-- TOC entry 4907 (class 2606 OID 16877)
-- Name: fallos fallos_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.fallos
    ADD CONSTRAINT fallos_pkey PRIMARY KEY (id_fallo);


--
-- TOC entry 4919 (class 2606 OID 17029)
-- Name: main_menu main_menu_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.main_menu
    ADD CONSTRAINT main_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 4905 (class 2606 OID 16869)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_rol);


--
-- TOC entry 4903 (class 2606 OID 16814)
-- Name: subcategoria subcategoria_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.subcategoria
    ADD CONSTRAINT subcategoria_pkey PRIMARY KEY (id_subcategoria);


--
-- TOC entry 4911 (class 2606 OID 16960)
-- Name: ticket_data ticket_data_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_data
    ADD CONSTRAINT ticket_data_pkey PRIMARY KEY (id_ticket);


--
-- TOC entry 4913 (class 2606 OID 16966)
-- Name: ticket_log ticket_log_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.ticket_log
    ADD CONSTRAINT ticket_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4887 (class 2606 OID 16778)
-- Name: tickets_data tickets_data_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.tickets_data
    ADD CONSTRAINT tickets_data_pkey PRIMARY KEY (id_ticket);


--
-- TOC entry 4897 (class 2606 OID 16817)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: tickets; Owner: TICKETSAPP
--

ALTER TABLE ONLY tickets.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA rh; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA rh TO "TICKETSAPP";
GRANT USAGE ON SCHEMA rh TO "RH";


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE departaments; Type: ACL; Schema: rh; Owner: RH
--

GRANT SELECT ON TABLE rh.departaments TO "TICKETSAPP";


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE roles; Type: ACL; Schema: rh; Owner: RH
--

GRANT SELECT ON TABLE rh.roles TO "TICKETSAPP";


--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE users; Type: ACL; Schema: rh; Owner: RH
--

GRANT SELECT,INSERT,UPDATE ON TABLE rh.users TO "TICKETSAPP";


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE sec_users; Type: ACL; Schema: rh; Owner: RH
--

GRANT ALL ON SEQUENCE rh.sec_users TO "TICKETSAPP";


-- Completed on 2026-05-22 16:12:23

--
-- PostgreSQL database dump complete
--

\unrestrict Jy9CHcWhXKmanENcyH06oQO6mdCfELe9miPJjqfKD0CWFYqEUG2DEehuAclWCmZ

