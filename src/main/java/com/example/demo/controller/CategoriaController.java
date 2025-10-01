package com.example.demo.controller;

import com.example.demo.entity.Categoria;
import com.example.demo.repository.CategoriaRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/categorias")
public class CategoriaController {

    private final CategoriaRepository repository;

    public CategoriaController(CategoriaRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("categorias", repository.findAll());
        return "categorias/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("categoria", new Categoria());
        return "categorias/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute Categoria categoria, BindingResult br) {
        if (br.hasErrors()) return "categorias/form";
        repository.save(categoria);
        return "redirect:/categorias";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        model.addAttribute("categoria", repository.findById(id).orElseThrow());
        return "categorias/form";
    }

    @PostMapping("/{id}")
    public String update(@PathVariable Long id, @Valid @ModelAttribute Categoria categoria, BindingResult br) {
        if (br.hasErrors()) return "categorias/form";
        categoria.setId(id);
        repository.save(categoria);
        return "redirect:/categorias";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        repository.deleteById(id);
        return "redirect:/categorias";
    }
}
