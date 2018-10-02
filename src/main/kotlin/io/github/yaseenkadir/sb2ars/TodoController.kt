package io.github.yaseenkadir.sb2ars

import org.slf4j.LoggerFactory
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/todos")
class TodoController(private val todoRepository: TodoRepository) {

    @PostMapping("")
    fun createTodo(@RequestBody todo: Todo): Todo {
        logger.info("Creating $todo")
        return todoRepository.save(todo)
    }

    @GetMapping("")
    fun getTodos(): Iterable<Todo> {
        logger.info("Getting todos")
        return todoRepository.findAll().toList()
    }

    @GetMapping("/{todoId}")
    fun getTodo(@PathVariable todoId: UUID): ResponseEntity<Any> {
        logger.info("Getting todo $todoId")
        val todo: Todo? = todoRepository.findById(todoId).orElse(null)

        if (todo == null) {
            logger.info("Todo with id $todoId does not exist")
            return ResponseEntity.notFound().build()
        }

        logger.info("Got $todo")
        return ResponseEntity.ok(todo)
    }

    companion object {
        private val logger = LoggerFactory.getLogger(TodoController::class.java)
    }
}
