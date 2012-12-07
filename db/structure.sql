--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admins (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE datasets (
    id bigint NOT NULL,
    name character varying(255),
    eid_of_owner character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_id_seq OWNED BY datasets.id;


--
-- Name: differential_expression_tests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE differential_expression_tests (
    id bigint NOT NULL,
    fpkm_sample_1_id bigint NOT NULL,
    fpkm_sample_2_id bigint NOT NULL,
    gene_id bigint,
    transcript_id bigint,
    test_status character varying(255),
    log_fold_change numeric,
    p_value numeric NOT NULL,
    q_value numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: differential_expression_tests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE differential_expression_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: differential_expression_tests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE differential_expression_tests_id_seq OWNED BY differential_expression_tests.id;


--
-- Name: fpkm_samples; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fpkm_samples (
    id bigint NOT NULL,
    gene_id bigint,
    transcript_id bigint,
    sample_name character varying(255) NOT NULL,
    fpkm numeric NOT NULL,
    fpkm_hi numeric,
    fpkm_lo numeric,
    status character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fpkm_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fpkm_samples_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fpkm_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fpkm_samples_id_seq OWNED BY fpkm_samples.id;


--
-- Name: gene_has_go_term; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gene_has_go_term (
    gene_id integer,
    go_term_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genes (
    id bigint NOT NULL,
    dataset_id bigint NOT NULL,
    name_from_program character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genes_id_seq OWNED BY genes.id;


--
-- Name: go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_terms (
    id character varying(255) NOT NULL,
    term character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job2s; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job2s (
    id bigint NOT NULL,
    eid_of_owner character varying(255),
    current_program_display_name character varying(255),
    workflow character varying(255),
    current_step character varying(255),
    next_step character varying(255),
    number_of_samples integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job2s_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job2s_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job2s_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job2s_id_seq OWNED BY job2s.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id bigint NOT NULL,
    current_job_status character varying(255),
    current_program_status character varying(255),
    email character varying(255) NOT NULL,
    workflow_step_id integer,
    output_files_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: transcripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transcripts (
    id bigint NOT NULL,
    dataset_id bigint NOT NULL,
    gene_id bigint,
    fasta_sequence text,
    name_from_program character varying(255) NOT NULL,
    fasta_description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transcripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transcripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transcripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transcripts_id_seq OWNED BY transcripts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets ALTER COLUMN id SET DEFAULT nextval('datasets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests ALTER COLUMN id SET DEFAULT nextval('differential_expression_tests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples ALTER COLUMN id SET DEFAULT nextval('fpkm_samples_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genes ALTER COLUMN id SET DEFAULT nextval('genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job2s ALTER COLUMN id SET DEFAULT nextval('job2s_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts ALTER COLUMN id SET DEFAULT nextval('transcripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: differential_expression_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_pkey PRIMARY KEY (id);


--
-- Name: fpkm_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_pkey PRIMARY KEY (id);


--
-- Name: genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_pkey PRIMARY KEY (id);


--
-- Name: go_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_terms
    ADD CONSTRAINT go_terms_pkey PRIMARY KEY (id);


--
-- Name: job2s_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job2s
    ADD CONSTRAINT job2s_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: transcripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transcripts_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: differential_expression_tests_fpkm_sample_1_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_fpkm_sample_1_fk FOREIGN KEY (fpkm_sample_1_id) REFERENCES fpkm_samples(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: differential_expression_tests_fpkm_sample_2_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_fpkm_sample_2_fk FOREIGN KEY (fpkm_sample_2_id) REFERENCES fpkm_samples(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: differential_expression_tests_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: differential_expression_tests_transcripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY differential_expression_tests
    ADD CONSTRAINT differential_expression_tests_transcripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fpkm_samples_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fpkm_samples_transcripts_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fpkm_samples
    ADD CONSTRAINT fpkm_samples_transcripts_fk FOREIGN KEY (transcript_id) REFERENCES transcripts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: genes_datasets_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transripts_datasets_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transripts_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transripts_genes_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcripts
    ADD CONSTRAINT transripts_genes_fk FOREIGN KEY (gene_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');