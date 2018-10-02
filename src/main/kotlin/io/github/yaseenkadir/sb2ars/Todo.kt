package io.github.yaseenkadir.sb2ars

import java.time.Instant
import java.util.UUID
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.Table
import javax.validation.constraints.NotBlank

@Entity
@Table(name = "todos")
data class Todo(
    @Id
    @Column(nullable = false, name = "todo_id")
    @GeneratedValue(strategy = GenerationType.AUTO)
    // If UUID is a duplicate Hibernate (or Postgres) will generate a new one for us
    val id: UUID = UUID.randomUUID(),

    @get:NotBlank
    @Column(nullable = false, name = "message")
    val message: String = "",

    @Column(nullable = false, name = "created_timestamp")
    val createdTimestamp: Instant = Instant.now(),

    @Column(nullable = false, name = "done")
    val done: Boolean = false
)
