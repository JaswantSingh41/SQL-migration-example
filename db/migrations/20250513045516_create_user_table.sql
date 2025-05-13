-- migrate:up
-- Create custom enum types
CREATE TYPE project_status AS ENUM ('active', 'completed', 'archived'); --for 1.data intergrity like 2 .good documentation 
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');
CREATE TYPE member_role AS ENUM ('owner', 'admin', 'member');

-- Create users table -- table name always use plural name users , ..
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- not null and always Uniqe  this is the Foriga
    email TEXT NOT NULL UNIQUE, -- in the postgres you have to mention the NOT null otherwise it can accept the null also 
    full_name TEXT NOT NULL, -- if your write Full Name --> postgres convert it to FullName or 
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create user_profiles table (one-to-one with users)  --user and userporfile diff , one to one means we use the primary key in user profile from the user table 
CREATE TABLE user_profiles (
    -- id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  --  we can remove this becuse it is not needed 
    -- user_id UUID NOT NULL UNIQUE REFERENCES users ON DELETE CASCADE,
    
    user_id UUID PRIMARY KEY REFERENCES users ON DELETE CASCADE, --Deletes any associated records in this table if the referenced user is deleted from the users table. it delect the user profile not like RESTRICT
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    status project_status NOT NULL DEFAULT 'active', -- using the ENUM type                                               
    owner_id UUID NOT NULL REFERENCES users ON DELETE RESTRICT, -- RESTRICT use and mantain --> referential integrity --> you cant delect user unless user dont delect the project frist 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

--Referential integrity 
-- 1 . RESTRICT
--2 . CASCADE
--3 . SET NULL 
--4 . SET DEFAULT

--Constraints 
--1 . UNIQE 
--2 . NOT NULL 
--3 . CHECK

-- Create tasks table (one-to-many with projects)-- we dont get the Primary key o project_table from user . we get project id which is not the primary key for this table 
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    priority INTEGER NOT NULL DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    status task_status NOT NULL DEFAULT 'pending',
    due_date DATE,
    assigned_to UUID REFERENCES users ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Linking Table
-- Create project_members table (many-to-many between projects and users) 
-- CREATE TABLE project_members (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     project_id UUID NOT NULL REFERENCES projects ON DELETE CASCADE,
--     user_id UUID NOT NULL REFERENCES users ON DELETE CASCADE,
--     role member_role NOT NULL DEFAULT 'member',
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     UNIQUE(project_id, user_id)
-- );
 -- many to many realtion / linking table and 
CREATE TABLE project_members (
    project_id UUID NOT NULL REFERENCES projects ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users ON DELETE CASCADE,
    role member_role NOT NULL DEFAULT 'member',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, user_id) -- we combine this to like project id 2 and userid 1 so 2 1 is the combination is the primary key of this table their not repated this combinations 
);



-- migrate:down
-- Drop tables if they exist
DROP TABLE IF EXISTS project_members;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS users;

-- Drop enum types if they exist
DROP TYPE IF EXISTS member_role;
DROP TYPE IF EXISTS task_status;
DROP TYPE IF EXISTS project_status;
