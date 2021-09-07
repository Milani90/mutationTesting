--
-- PostgreSQL database dump
--

-- Dumped from database version 10.11
-- Dumped by pg_dump version 10.11

-- Started on 2021-09-07 09:27:27

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE tfm;
--
-- TOC entry 2918 (class 1262 OID 18442)
-- Name: tfm; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE tfm WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';


ALTER DATABASE tfm OWNER TO postgres;

\connect tfm

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12924)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2921 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 208 (class 1259 OID 18514)
-- Name: execution_tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.execution_tests (
    idmutacion integer NOT NULL,
    idtest integer NOT NULL,
    veredicto boolean NOT NULL
);


ALTER TABLE public.execution_tests OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 18745)
-- Name: mutations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mutations (
    idmutation integer NOT NULL,
    triggername character varying(30),
    functionname character varying(30),
    triggerbody text,
    functionbody text,
    login character varying(30),
    idtrigger integer,
    idoperator integer,
    equivalent boolean,
    change character varying(50),
    type character varying(10)
);


ALTER TABLE public.mutations OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 18499)
-- Name: test_suites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_suites (
    idsuite integer NOT NULL,
    idtest integer NOT NULL
);


ALTER TABLE public.test_suites OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 166631)
-- Name: ExecutionMutantsView; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."ExecutionMutantsView" AS
 SELECT mutations.idmutation,
    mutations.triggername,
    mutations.functionname,
    mutations.triggerbody,
    mutations.functionbody,
    mutations.login,
    mutations.idtrigger,
    mutations.idoperator,
    mutations.type,
    test_suites.idsuite,
    execution_tests.idtest
   FROM public.mutations,
    public.execution_tests,
    public.test_suites
  WHERE ((NOT mutations.equivalent) AND (mutations.idmutation = execution_tests.idmutacion) AND (test_suites.idtest = execution_tests.idtest));


ALTER TABLE public."ExecutionMutantsView" OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 166627)
-- Name: ExecutionView; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."ExecutionView" AS
SELECT
    NULL::integer AS idmutation,
    NULL::character varying(50) AS change,
    NULL::character varying(6) AS name,
    NULL::integer AS idoperator,
    NULL::integer AS idtrigger,
    NULL::integer AS idsuite,
    NULL::boolean AS veredicto,
    NULL::bigint AS numtests,
    NULL::boolean AS equivalent;


ALTER TABLE public."ExecutionView" OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 18450)
-- Name: operators; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operators (
    idoper integer NOT NULL,
    name character varying(6) NOT NULL,
    description text NOT NULL,
    code text NOT NULL,
    owner character varying(30) NOT NULL
);


ALTER TABLE public.operators OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 257780)
-- Name: MutantsKilledView; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."MutantsKilledView" AS
 SELECT DISTINCT mutations.idmutation,
    mutations.change,
    operators.name,
    mutations.idoperator,
    mutations.idtrigger,
    test_suites.idsuite
   FROM public.mutations,
    public.execution_tests,
    public.operators,
    public.test_suites
  WHERE ((mutations.idmutation = execution_tests.idmutacion) AND (mutations.idoperator = operators.idoper) AND (test_suites.idtest = execution_tests.idtest) AND (execution_tests.veredicto = true));


ALTER TABLE public."MutantsKilledView" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 257784)
-- Name: MutantsAliveView; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."MutantsAliveView" AS
 SELECT DISTINCT mutations.idmutation,
    mutations.change,
    operators.name,
    mutations.idoperator,
    mutations.idtrigger,
    t.idsuite,
    mutations.equivalent
   FROM public.mutations,
    public.execution_tests,
    public.operators,
    public.test_suites t
  WHERE ((mutations.idmutation = execution_tests.idmutacion) AND (mutations.idoperator = operators.idoper) AND (t.idtest = execution_tests.idtest) AND (execution_tests.veredicto = false) AND (NOT (mutations.idmutation IN ( SELECT "MutantsKilledView".idmutation
           FROM public."MutantsKilledView"
          WHERE ("MutantsKilledView".idsuite = t.idsuite)))));


ALTER TABLE public."MutantsAliveView" OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 18490)
-- Name: tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tests (
    idtest integer NOT NULL,
    test character varying(500) NOT NULL,
    databasename character varying(20) NOT NULL
);


ALTER TABLE public.tests OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 155986)
-- Name: TestSuiteView; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."TestSuiteView" AS
 SELECT test_suites.idsuite,
    tests.idtest,
    tests.test
   FROM public.test_suites,
    public.tests
  WHERE (test_suites.idtest = tests.idtest);


ALTER TABLE public."TestSuiteView" OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 104149)
-- Name: mutationsView; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."mutationsView" WITH (security_barrier='false') AS
 SELECT mutations.idmutation,
    mutations.type,
    mutations.change,
    operators.name,
    mutations.idoperator,
    mutations.idtrigger,
    mutations.triggername,
    mutations.functionname,
    mutations.triggerbody,
    mutations.functionbody
   FROM public.mutations,
    public.operators
  WHERE (mutations.idoperator = operators.idoper);


ALTER TABLE public."mutationsView" OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 18743)
-- Name: mutations_idmutation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mutations_idmutation_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mutations_idmutation_seq OWNER TO postgres;

--
-- TOC entry 2922 (class 0 OID 0)
-- Dependencies: 209
-- Name: mutations_idmutation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mutations_idmutation_seq OWNED BY public.mutations.idmutation;


--
-- TOC entry 199 (class 1259 OID 18448)
-- Name: operators_idoper_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.operators_idoper_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.operators_idoper_seq OWNER TO postgres;

--
-- TOC entry 2923 (class 0 OID 0)
-- Dependencies: 199
-- Name: operators_idoper_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.operators_idoper_seq OWNED BY public.operators.idoper;


--
-- TOC entry 204 (class 1259 OID 18477)
-- Name: suites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suites (
    idsuite integer NOT NULL,
    description character varying(250) NOT NULL,
    login character varying(30) NOT NULL,
    databasename character varying(20) NOT NULL
);


ALTER TABLE public.suites OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 18475)
-- Name: suites_idsuite_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suites_idsuite_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suites_idsuite_seq OWNER TO postgres;

--
-- TOC entry 2924 (class 0 OID 0)
-- Dependencies: 203
-- Name: suites_idsuite_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suites_idsuite_seq OWNED BY public.suites.idsuite;


--
-- TOC entry 205 (class 1259 OID 18488)
-- Name: tests_idtest_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tests_idtest_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tests_idtest_seq OWNER TO postgres;

--
-- TOC entry 2925 (class 0 OID 0)
-- Dependencies: 205
-- Name: tests_idtest_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tests_idtest_seq OWNED BY public.tests.idtest;


--
-- TOC entry 202 (class 1259 OID 18461)
-- Name: triggers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.triggers (
    idtrigger integer NOT NULL,
    name character varying(30) NOT NULL,
    headertrigger text NOT NULL,
    bodytrigger text NOT NULL,
    login character varying(30) NOT NULL,
    databasename character varying(20) NOT NULL,
    description character varying(250) NOT NULL
);


ALTER TABLE public.triggers OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 18459)
-- Name: triggers_idtrigger_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.triggers_idtrigger_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.triggers_idtrigger_seq OWNER TO postgres;

--
-- TOC entry 2926 (class 0 OID 0)
-- Dependencies: 201
-- Name: triggers_idtrigger_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.triggers_idtrigger_seq OWNED BY public.triggers.idtrigger;


--
-- TOC entry 198 (class 1259 OID 18443)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    login character varying(30) NOT NULL,
    password character varying(30) NOT NULL,
    compartirinfo boolean
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 2740 (class 2604 OID 18748)
-- Name: mutations idmutation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutations ALTER COLUMN idmutation SET DEFAULT nextval('public.mutations_idmutation_seq'::regclass);


--
-- TOC entry 2736 (class 2604 OID 18453)
-- Name: operators idoper; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operators ALTER COLUMN idoper SET DEFAULT nextval('public.operators_idoper_seq'::regclass);


--
-- TOC entry 2738 (class 2604 OID 18480)
-- Name: suites idsuite; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suites ALTER COLUMN idsuite SET DEFAULT nextval('public.suites_idsuite_seq'::regclass);


--
-- TOC entry 2739 (class 2604 OID 18493)
-- Name: tests idtest; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests ALTER COLUMN idtest SET DEFAULT nextval('public.tests_idtest_seq'::regclass);


--
-- TOC entry 2737 (class 2604 OID 18464)
-- Name: triggers idtrigger; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers ALTER COLUMN idtrigger SET DEFAULT nextval('public.triggers_idtrigger_seq'::regclass);



--
-- TOC entry 2902 (class 0 OID 18450)
-- Dependencies: 200
-- Data for Name: operators; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (8, 'ARREP', 'Replace arithmetic operator (+,-,*,/)', 'function CAO(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (15, 'ARREPH', 'Replace arithmetic operator (+,-,*,/) in header', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (19, 'NTDELH', 'Remove logical operator NOT in header', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (10, 'REPTIM', 'Replace AFTER - BEFORE', 'function CBT(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (12, 'DELWC', 'Remove WHEN clause from statement', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (14, 'RLREP', 'Replace relational operator (=;<>;<;<=;>;>=)', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (16, 'RLREPH', 'Replace relational operator (=;<>;<;<=;>;>=) in header', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (17, 'LGREPH', 'Replace logical operator (OR - AND) in header', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (9, 'LGREP', 'Replace logical operator (OR - AND)', 'function CLO(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (11, 'REPRLV', 'Replace row operator', 'function CRO(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (1, 'VARREP', 'Replace NEW - OLD', 'function CNO(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (13, 'NTDEL', 'Remove logical operator NOT', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (2, 'ADDEC', 'Add event clause', 'function(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (3, 'DELEC', 'Delete event clause', 'function ADU(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (4, 'REPEC', 'Replace event clause', 'function ADD(){}', 'tfm');
INSERT INTO public.operators (idoper, name, description, code, owner) VALUES (18, 'VAREPH', 'Replace NEW - OLD in header', 'function(){}', 'tfm');



--
-- TOC entry 2927 (class 0 OID 0)
-- Dependencies: 209
-- Name: mutations_idmutation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mutations_idmutation_seq', 22200, true);


--
-- TOC entry 2928 (class 0 OID 0)
-- Dependencies: 199
-- Name: operators_idoper_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.operators_idoper_seq', 40, true);


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 203
-- Name: suites_idsuite_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suites_idsuite_seq', 410, true);


--
-- TOC entry 2930 (class 0 OID 0)
-- Dependencies: 205
-- Name: tests_idtest_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tests_idtest_seq', 697, true);


--
-- TOC entry 2931 (class 0 OID 0)
-- Dependencies: 201
-- Name: triggers_idtrigger_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.triggers_idtrigger_seq', 268, true);


--
-- TOC entry 2762 (class 2606 OID 18753)
-- Name: mutations mutations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutations
    ADD CONSTRAINT mutations_pkey PRIMARY KEY (idmutation);


--
-- TOC entry 2744 (class 2606 OID 26978)
-- Name: operators operators_idoperator_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_idoperator_unique UNIQUE (idoper);


--
-- TOC entry 2760 (class 2606 OID 18518)
-- Name: execution_tests pk_execution_tests; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.execution_tests
    ADD CONSTRAINT pk_execution_tests PRIMARY KEY (idmutacion, idtest);


--
-- TOC entry 2746 (class 2606 OID 45900)
-- Name: operators pk_operators; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT pk_operators PRIMARY KEY (name);


--
-- TOC entry 2754 (class 2606 OID 18482)
-- Name: suites pk_suites; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suites
    ADD CONSTRAINT pk_suites PRIMARY KEY (idsuite);


--
-- TOC entry 2758 (class 2606 OID 18503)
-- Name: test_suites pk_test_suites; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_suites
    ADD CONSTRAINT pk_test_suites PRIMARY KEY (idsuite, idtest);


--
-- TOC entry 2756 (class 2606 OID 18498)
-- Name: tests pk_tests; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT pk_tests PRIMARY KEY (idtest);


--
-- TOC entry 2748 (class 2606 OID 18469)
-- Name: triggers pk_triggers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT pk_triggers PRIMARY KEY (name, login);


--
-- TOC entry 2742 (class 2606 OID 18447)
-- Name: users pk_users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT pk_users PRIMARY KEY (login);


--
-- TOC entry 2750 (class 2606 OID 26985)
-- Name: triggers uk_idtrigger; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT uk_idtrigger UNIQUE (idtrigger);


--
-- TOC entry 2752 (class 2606 OID 18706)
-- Name: triggers uk_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT uk_name UNIQUE (name);


--
-- TOC entry 2896 (class 2618 OID 166630)
-- Name: ExecutionView _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public."ExecutionView" WITH (security_barrier='false') AS
 SELECT mutations.idmutation,
    mutations.change,
    operators.name,
    mutations.idoperator,
    mutations.idtrigger,
    test_suites.idsuite,
    execution_tests.veredicto,
    count(*) AS numtests,
    mutations.equivalent
   FROM public.mutations,
    public.execution_tests,
    public.operators,
    public.test_suites
  WHERE ((mutations.idmutation = execution_tests.idmutacion) AND (mutations.idoperator = operators.idoper) AND (test_suites.idtest = execution_tests.idtest))
  GROUP BY mutations.idmutation, mutations.change, operators.name, mutations.idoperator, mutations.idtrigger, test_suites.idsuite, execution_tests.veredicto;


--
-- TOC entry 2769 (class 2606 OID 26967)
-- Name: execution_tests execution_tests_idmutation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.execution_tests
    ADD CONSTRAINT execution_tests_idmutation_fkey FOREIGN KEY (idmutacion) REFERENCES public.mutations(idmutation) NOT VALID;


--
-- TOC entry 2768 (class 2606 OID 18519)
-- Name: execution_tests execution_tests_idtest_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.execution_tests
    ADD CONSTRAINT execution_tests_idtest_fkey FOREIGN KEY (idtest) REFERENCES public.tests(idtest);


--
-- TOC entry 2771 (class 2606 OID 26979)
-- Name: mutations mutations_idoperator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutations
    ADD CONSTRAINT mutations_idoperator_fkey FOREIGN KEY (idoperator) REFERENCES public.operators(idoper) NOT VALID;


--
-- TOC entry 2772 (class 2606 OID 26986)
-- Name: mutations mutations_idtrigger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutations
    ADD CONSTRAINT mutations_idtrigger_fkey FOREIGN KEY (idtrigger) REFERENCES public.triggers(idtrigger) NOT VALID;


--
-- TOC entry 2770 (class 2606 OID 26972)
-- Name: mutations mutations_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutations
    ADD CONSTRAINT mutations_login_fkey FOREIGN KEY (login) REFERENCES public.users(login) NOT VALID;


--
-- TOC entry 2763 (class 2606 OID 26962)
-- Name: operators operators_owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_owner_fkey FOREIGN KEY (owner) REFERENCES public.users(login) NOT VALID;


--
-- TOC entry 2765 (class 2606 OID 18483)
-- Name: suites suites_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suites
    ADD CONSTRAINT suites_login_fkey FOREIGN KEY (login) REFERENCES public.users(login);


--
-- TOC entry 2766 (class 2606 OID 18504)
-- Name: test_suites test_suites_idsuite_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_suites
    ADD CONSTRAINT test_suites_idsuite_fkey FOREIGN KEY (idsuite) REFERENCES public.suites(idsuite);


--
-- TOC entry 2767 (class 2606 OID 18509)
-- Name: test_suites test_suites_idtest_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_suites
    ADD CONSTRAINT test_suites_idtest_fkey FOREIGN KEY (idtest) REFERENCES public.tests(idtest);


--
-- TOC entry 2764 (class 2606 OID 18470)
-- Name: triggers triggers_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT triggers_login_fkey FOREIGN KEY (login) REFERENCES public.users(login);


--
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2021-09-07 09:27:27

--
-- PostgreSQL database dump complete
--

