package com.example.demo;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.example.demo.entity.Categoria;
import com.example.demo.entity.Curso;
import com.example.demo.entity.Professor;
import com.example.demo.repository.CategoriaRepository;
import com.example.demo.repository.CursoRepository;
import com.example.demo.repository.ProfessorRepository;

@Component
public class DevData implements CommandLineRunner {

    private final ProfessorRepository profRepo;
    private final CategoriaRepository catRepo;
    private final CursoRepository cursoRepo;

    public DevData(ProfessorRepository profRepo,
                   CategoriaRepository catRepo,
                   CursoRepository cursoRepo) {
        this.profRepo = profRepo;
        this.catRepo = catRepo;
        this.cursoRepo = cursoRepo;
    }

    @Override
    public void run(String... args) {
        seedProfessores();
        seedCategorias();
        seedCursos();
    }

    private void seedProfessores() {
        if (profRepo.count() > 0) return;

        List<Professor> list = new ArrayList<>();

        Professor p1 = new Professor();
        p1.setNome("Ana Lima");
        p1.setEmail("ana@if.com");
        p1.setImagem("https://picsum.photos/seed/ana/200");
        list.add(p1);

        Professor p2 = new Professor();
        p2.setNome("Bruno Souza");
        p2.setEmail("bruno@if.com");
        p2.setImagem("https://picsum.photos/seed/bruno/200");
        list.add(p2);

        Professor p3 = new Professor();
        p3.setNome("Carla Dias");
        p3.setEmail("carla@if.com");
        p3.setImagem("https://picsum.photos/seed/carla/200");
        list.add(p3);

        profRepo.saveAll(list);
    }

    private void seedCategorias() {
        if (catRepo.count() > 0) return;

        List<Categoria> list = new ArrayList<>();

        Categoria c1 = new Categoria();
        c1.setNome("Programação");
        list.add(c1);

        Categoria c2 = new Categoria();
        c2.setNome("Design");
        list.add(c2);

        Categoria c3 = new Categoria();
        c3.setNome("Dados");
        list.add(c3);

        catRepo.saveAll(list);
    }

    private void seedCursos() {
        if (cursoRepo.count() > 0) return;

        // pegar alguns registros já salvos
        Professor ana   = profRepo.findAll().stream().findFirst().orElse(null);
        Professor bruno = profRepo.findAll().stream().skip(1).findFirst().orElse(ana);

        Categoria prog  = catRepo.findAll().stream()
                .filter(c -> "Programação".equalsIgnoreCase(c.getNome()))
                .findFirst().orElse(catRepo.findAll().get(0));

        Categoria design = catRepo.findAll().stream()
                .filter(c -> "Design".equalsIgnoreCase(c.getNome()))
                .findFirst().orElse(catRepo.findAll().get(0));

        List<Curso> list = new ArrayList<>();

        Curso a = new Curso();
        a.setNome("Java Web");
        a.setDescricao("Spring Boot + Thymeleaf + CRUD");
        a.setDataInicio(LocalDate.now().minusDays(10));
        a.setDataFinal(LocalDate.now().plusMonths(2));
        a.setImagem("https://picsum.photos/seed/java/600/300");
        a.setProfessor(ana);
        a.setCategoria(prog);
        list.add(a);

        Curso b = new Curso();
        b.setNome("UX Básico");
        b.setDescricao("Fundamentos de UX/UI e prototipação");
        b.setDataInicio(LocalDate.now().minusDays(5));
        b.setDataFinal(LocalDate.now().plusMonths(1));
        b.setImagem("https://picsum.photos/seed/ux/600/300");
        b.setProfessor(bruno);
        b.setCategoria(design);
        list.add(b);

        cursoRepo.saveAll(list);
    }
}