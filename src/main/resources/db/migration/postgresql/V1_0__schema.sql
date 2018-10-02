/* Using a UUID for the pk of a todo, be sure to enable the pgcrypto extension for this database */
CREATE TABLE todos (
    todo_id           UUID                      NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    message           VARCHAR(100)              NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE  NOT NULL,
    done              BOOLEAN                   NOT NULL
);
