
CREATE TABLE todos (
    todo_id           UUID IDENTITY PRIMARY KEY,
    message           VARCHAR(100) NOT NULL,
    created_timestamp TIMESTAMP WITH TIME ZONE  NOT NULL,
    done              BOOLEAN                   NOT NULL
);
