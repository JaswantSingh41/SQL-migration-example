-- migrate:up
-- Seed users first and store their IDs in variables
WITH inserted_users AS (
    INSERT INTO users (email, full_name, password_hash) VALUES
    ('john@example.com', 'John Doe', 'hash1'),
    ('jane@example.com', 'Jane Smith', 'hash2'),
    ('bob@example.com', 'Bob Wilson', 'hash3'),
    ('alice@example.com', 'Alice Brown', 'hash4')
    RETURNING id, email
),
-- Seed user profiles
inserted_profiles AS (
    INSERT INTO user_profiles (user_id, avatar_url, bio, phone)
    SELECT
        id,
        'https://example.com/avatar' || row_number() OVER () || '.jpg',
        CASE
            WHEN email LIKE 'john%' THEN 'Project Manager with 5 years experience'
            WHEN email LIKE 'jane%' THEN 'Senior Developer'
            WHEN email LIKE 'bob%' THEN 'UX Designer'
            ELSE 'Business Analyst'
        END,
        '+123456789' || row_number() OVER ()
    FROM inserted_users
),
-- Seed projects
inserted_projects AS (
    INSERT INTO projects (name, description, status, owner_id)
    SELECT
        unnest(ARRAY[
            'Website Redesign',
            'Mobile App Development',
            'Database Migration'
        ]),
        unnest(ARRAY[
            'Complete overhaul of company website',
            'New mobile app for customers',
            'Migrate legacy database to new system'
        ]),
        unnest(ARRAY[
            'active',
            'active',
            'active'
        ])::project_status,
        (SELECT id FROM inserted_users WHERE email = 'john@example.com')
    RETURNING id, name
),
-- Seed tasks
inserted_tasks AS (
    INSERT INTO tasks (project_id, title, description, priority, status, due_date, assigned_to)
    SELECT
        p.id,
        t.title,
        t.description,
        t.priority,
        t.status::task_status,
        t.due_date,
        u.id
    FROM (
        SELECT 'Website Redesign' AS project_name, 'Design Homepage' AS title, 'Create new homepage design' AS description, 1 AS priority, 'pending' AS status, '2024-01-01'::date AS due_date, 'bob@example.com' AS assignee
        UNION ALL
        SELECT 'Website Redesign', 'Implement Frontend', 'Create new homepage design', 2, 'pending', '2024-01-05', 'alice@example.com'
        UNION ALL
        SELECT 'Mobile App Development', 'User Authentication', 'Develop user authentication features', 1, 'in_progress', '2024-02-15', 'jane@example.com'
        UNION ALL
        SELECT 'Database Migration', 'Write migration scripts', 'Create database migration scripts', 1, 'in_progress', '2024-03-01', 'john@example.com'
    ) t
    JOIN inserted_projects p ON p.name = t.project_name
    JOIN inserted_users u ON u.email = t.assignee
),
-- Seed project_members
inserted_project_members AS (
    INSERT INTO project_members (project_id, user_id, role)
    SELECT
        p.id,
        u.id,
        m.role::member_role
    FROM (
        SELECT
            'Website Redesign' as project_name,
            'john@example.com' as user_email,
            'owner' as role
        UNION ALL
        SELECT 'Website Redesign', 'jane@example.com', 'member'
        UNION ALL
        SELECT 'Website Redesign', 'bob@example.com', 'member'
        UNION ALL
        SELECT 'Mobile App Development', 'john@example.com', 'owner'
        UNION ALL
        SELECT 'Mobile App Development', 'bob@example.com', 'admin'
        UNION ALL
        SELECT 'Mobile App Development', 'alice@example.com', 'member'
        UNION ALL
        SELECT 'Database Migration', 'john@example.com', 'owner'
        UNION ALL
        SELECT 'Database Migration', 'jane@example.com', 'member'
        UNION ALL
        SELECT 'Database Migration', 'alice@example.com', 'admin'
    ) m
    JOIN inserted_projects p ON p.name = m.project_name
    JOIN inserted_users u ON u.email = m.user_email
)
SELECT 'Migration completed successfully' AS result;

-- migrate:down

-- Clear all data
TRUNCATE TABLE project_members CASCADE;
TRUNCATE TABLE tasks CASCADE;
TRUNCATE TABLE projects CASCADE;
TRUNCATE TABLE user_profiles CASCADE;
TRUNCATE TABLE users CASCADE;