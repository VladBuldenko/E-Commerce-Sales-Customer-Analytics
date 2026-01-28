-- 1. Create schemas for the project

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;

-- 2. Create a dedicated schema for cleaned, business-ready data
CREATE SCHEMA IF NOT EXISTS mart;