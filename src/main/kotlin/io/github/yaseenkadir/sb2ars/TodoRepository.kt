package io.github.yaseenkadir.sb2ars

import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface TodoRepository: JpaRepository<Todo, UUID>
