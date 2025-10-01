package com.example.demo.repository;

import com.example.demo.entity.Curso;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CursoRepository extends JpaRepository<Curso, Long> {
    List<Curso> findByCategoriaId(Long categoriaId);
    List<Curso> findByProfessorId(Long professorId);
    List<Curso> findByNomeContainingIgnoreCase(String nome);
}
