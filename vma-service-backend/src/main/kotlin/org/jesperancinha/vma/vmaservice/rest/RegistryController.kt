package org.jesperancinha.vma.vmaservice.rest

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import org.jesperancinha.vma.common.dto.CategoryDto
import org.jesperancinha.vma.vmaservice.service.CategoryService
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("registry")
class RegistryController(
    val categoryService: CategoryService
) {
    @PostMapping
    fun createCategories(
        @RequestBody
        registryDtos: List<CategoryDto>
    ): Flow<CategoryDto> {
        return categoryService.createRegistry(registryDtos.asFlow())
    }

    @PostMapping("/random")
    fun createRandomVma(
    ) {

    }

}