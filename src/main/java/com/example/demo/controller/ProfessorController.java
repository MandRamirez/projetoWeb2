package com.example.demo.controller;

import com.example.demo.entity.Professor;
import com.example.demo.repository.ProfessorRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/professores")
public class ProfessorController {

    private final ProfessorRepository repository;

    public ProfessorController(ProfessorRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("professores", repository.findAll());
        return "professores/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("professor", new Professor());
        return "professores/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute Professor professor, BindingResult br) {
        if (br.hasErrors()) return "professores/form";
        repository.save(professor);
        return "redirect:/professores";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        model.addAttribute("professor", repository.findById(id).orElseThrow());
        return "professores/form";
    }

    @PostMapping("/{id}")
    public String update(@PathVariable Long id, @Valid @ModelAttribute Professor professor, BindingResult br) {
        if (br.hasErrors()) return "professores/form";
        professor.setId(id);
        repository.save(professor);
        return "redirect:/professores";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        repository.deleteById(id);
        return "redirect:/professores";
    }
}
