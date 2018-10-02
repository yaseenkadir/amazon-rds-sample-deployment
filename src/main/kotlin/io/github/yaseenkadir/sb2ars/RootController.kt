package io.github.yaseenkadir.sb2ars

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class RootController {

    @RequestMapping("")
    fun status(): Map<String, String> {
        LOGGER.info("Getting status")
        return mapOf("status" to "UP")
    }

    companion object {
        private val LOGGER = LoggerFactory.getLogger(RootController::class.java)
    }
}
