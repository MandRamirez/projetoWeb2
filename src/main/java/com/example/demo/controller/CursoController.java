package com.example.demo.controller;

import com.example.demo.entity.Curso;
import com.example.demo.repository.CategoriaRepository;
import com.example.demo.repository.CursoRepository;
import com.example.demo.repository.ProfessorRepository;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@Controller
@RequestMapping("/cursos")
public class CursoController {

    private final CursoRepository repository;
    private final CategoriaRepository categoriaRepository;
    private final ProfessorRepository professorRepository;

    public CursoController(CursoRepository repository,
                           CategoriaRepository categoriaRepository,
                           ProfessorRepository professorRepository) {
        this.repository = repository;
        this.categoriaRepository = categoriaRepository;
        this.professorRepository = professorRepository;
    }

    @GetMapping
    public String list(@RequestParam(value="categoriaId", required=false) Long categoriaId, Model model) {
        model.addAttribute("categorias", categoriaRepository.findAll());
        if (categoriaId != null) {
            model.addAttribute("cursos", repository.findByCategoriaId(categoriaId));
            model.addAttribute("categoriaSelecionada", categoriaId);
        } else {
            model.addAttribute("cursos", repository.findAll());
        }
        return "cursos/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("curso", new Curso());
        model.addAttribute("categorias", categoriaRepository.findAll());
        model.addAttribute("professores", professorRepository.findAll());
        return "cursos/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute Curso curso, BindingResult br,
                         @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataInicio,
                         @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataFinal) {
        if (br.hasErrors()) return "cursos/form";
        curso.setDataInicio(dataInicio);
        curso.setDataFinal(dataFinal);
        repository.save(curso);
        return "redirect:/cursos";
    }

    @GetMapping("/{id}")
    public String details(@PathVariable Long id, Model model) {
        model.addAttribute("curso", repository.findById(id).orElseThrow());
        return "cursos/details";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        model.addAttribute("curso", repository.findById(id).orElseThrow());
        model.addAttribute("categorias", categoriaRepository.findAll());
        model.addAttribute("professores", professorRepository.findAll());
        return "cursos/form";
    }

    @PostMapping("/{id}")
    public String update(@PathVariable Long id, @Valid @ModelAttribute Curso curso, BindingResult br,
                         @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataInicio,
                         @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataFinal) {
        if (br.hasErrors()) return "cursos/form";
        curso.setId(id);
        curso.setDataInicio(dataInicio);
        curso.setDataFinal(dataFinal);
        repository.save(curso);
        return "redirect:/cursos";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        repository.deleteById(id);
        return "redirect:/cursos";
    }
}
