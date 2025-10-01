
param(
  [string]$ProjectDir = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Ensure we're in the project folder (contains pom.xml)
$pom = Join-Path $ProjectDir "pom.xml"
if (-not (Test-Path $pom)) {
  Write-Error "Execute este script dentro da pasta do projeto (onde está o pom.xml) ou passe -ProjectDir 'caminho'."
}

function Ensure-Dir($path) {
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

# Paths
$pkgPath = "com\example\demo"
$srcJava = Join-Path $ProjectDir ("src\main\java\" + $pkgPath)
$srcRes  = Join-Path $ProjectDir "src\main\resources"

# Create dirs
Ensure-Dir (Join-Path $srcJava "entity")
Ensure-Dir (Join-Path $srcJava "repository")
Ensure-Dir (Join-Path $srcJava "controller")
Ensure-Dir (Join-Path $srcRes  "templates\categorias")
Ensure-Dir (Join-Path $srcRes  "templates\professores")
Ensure-Dir (Join-Path $srcRes  "templates\cursos")
Ensure-Dir (Join-Path $srcRes  "static\css")

# Files content (here-strings)
$pomXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.5.5</version>
    <relativePath/>
  </parent>

  <groupId>br.if</groupId>
  <artifactId>atividade1</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>atividade1</name>
  <description>Atividade 1 - CRUD Professores, Categorias, Cursos</description>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
'@
$appProps = @'
spring.application.name=atividade1

# H2 database (arquivo local ./data/atividade1)
spring.datasource.url=jdbc:h2:file:./data/atividade1;DB_CLOSE_DELAY=-1;MODE=MySQL
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.h2.console.enabled=true
spring.h2.console.path=/h2

# Thymeleaf
spring.thymeleaf.cache=false
'@
$categoria = @'
package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Categoria {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Nome é obrigatório")
    @Column(nullable = false, unique = true)
    private String nome;
}
'@
$professor = @'
package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Professor {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Nome é obrigatório")
    @Column(nullable = false)
    private String nome;

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email inválido")
    @Column(nullable = false, unique = true)
    private String email;

    // Link/URL da imagem (para simplificar; pode ser upload futuro)
    private String imagem;
}
'@
$curso = @'
package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.time.LocalDate;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Curso {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Nome é obrigatório")
    @Column(nullable = false)
    private String nome;

    @Size(max = 2000)
    @Column(length = 2000)
    private String descricao;

    private LocalDate dataInicio;
    private LocalDate dataFinal;

    // Link/URL da imagem do curso
    private String imagem;

    @ManyToOne(optional = false)
    private Categoria categoria;

    @ManyToOne(optional = false)
    private Professor professor;
}
'@
$repoCategoria = @'
package com.example.demo.repository;

import com.example.demo.entity.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoriaRepository extends JpaRepository<Categoria, Long> {
}
'@
$repoProfessor = @'
package com.example.demo.repository;

import com.example.demo.entity.Professor;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProfessorRepository extends JpaRepository<Professor, Long> {
}
'@
$repoCurso = @'
package com.example.demo.repository;

import com.example.demo.entity.Curso;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CursoRepository extends JpaRepository<Curso, Long> {
    List<Curso> findByCategoriaId(Long categoriaId);
    List<Curso> findByNomeContainingIgnoreCase(String q);
}
'@
$homeController = @'
package com.example.demo.controller;

import com.example.demo.repository.CategoriaRepository;
import com.example.demo.repository.CursoRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomeController {

    private final CategoriaRepository categoriaRepository;
    private final CursoRepository cursoRepository;

    public HomeController(CategoriaRepository categoriaRepository, CursoRepository cursoRepository) {
        this.categoriaRepository = categoriaRepository;
        this.cursoRepository = cursoRepository;
    }

    @GetMapping({"/", "/home"})
    public String index(@RequestParam(value = "q", required = false) String q, Model model) {
        model.addAttribute("categorias", categoriaRepository.findAll());
        if (q != null && !q.isBlank()) {
            model.addAttribute("cursos", cursoRepository.findByNomeContainingIgnoreCase(q));
            model.addAttribute("busca", q);
        }
        return "index";
    }
}
'@
$categoriaController = @'
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
'@
$professorController = @'
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
'@
$cursoController = @'
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
'@
$fragments = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8"/>
    <title th:text="${title} ?: 'Atividade 1'">Atividade 1</title>
    <link th:href="@{/css/style.css}" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
  <div class="container">
    <a class="navbar-brand" th:href="@{/}">Atividade 1</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" th:href="@{/cursos}">Cursos</a></li>
        <li class="nav-item"><a class="nav-link" th:href="@{/professores}">Professores</a></li>
        <li class="nav-item"><a class="nav-link" th:href="@{/categorias}">Categorias</a></li>
        <li class="nav-item"><a class="nav-link" th:href="@{/h2}" target="_blank">H2</a></li>
      </ul>
      <form class="d-flex" th:action="@{/}" method="get">
        <input class="form-control me-2" type="search" name="q" placeholder="Buscar curso" th:value="${busca}"/>
        <button class="btn btn-outline-light" type="submit">Buscar</button>
      </form>
    </div>
  </div>
</nav>
<div class="container" th:fragment="content">
    <!-- content -->
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
'@
$indexTpl = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <div class="mb-4">
    <h2>Categorias</h2>
    <div class="d-flex flex-wrap gap-2">
      <a class="btn btn-sm btn-secondary" th:each="c : ${categorias}" th:text="${c.nome}" th:href="@{|/cursos?categoriaId=${c.id}|}"></a>
    </div>
  </div>
  <div th:if="${cursos != null}">
    <h2 th:text="'Resultados para \"' + ${busca} + '\"'">Resultados</h2>
    <div class="row row-cols-1 row-cols-md-3 g-3">
      <div class="col" th:each="curso : ${cursos}">
        <div class="card h-100">
          <img th:if="${curso.imagem}" th:src="${curso.imagem}" class="card-img-top" alt="imagem">
          <div class="card-body">
            <h5 class="card-title" th:text="${curso.nome}">Nome</h5>
            <p class="card-text" th:text="${#strings.abbreviate(curso.descricao, 160)}">Descrição</p>
            <a class="btn btn-primary" th:href="@{|/cursos/${curso.id}|}">Ver detalhes</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</html>
'@
$catList = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2>Categorias</h2>
    <a class="btn btn-success" th:href="@{/categorias/new}">Nova Categoria</a>
  </div>
  <table class="table table-striped">
    <thead><tr><th>ID</th><th>Nome</th><th style="width:180px">Ações</th></tr></thead>
    <tbody>
      <tr th:each="c : ${categorias}">
        <td th:text="${c.id}">1</td>
        <td th:text="${c.nome}">Nome</td>
        <td>
          <a class="btn btn-sm btn-primary" th:href="@{|/categorias/${c.id}/edit|}">Editar</a>
          <form th:action="@{|/categorias/${c.id}/delete|}" method="post" class="d-inline">
            <button class="btn btn-sm btn-danger" onclick="return confirm('Excluir?')">Excluir</button>
          </form>
        </td>
      </tr>
    </tbody>
  </table>
</div>
</html>
'@
$catForm = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <h2 th:text="${categoria.id} != null ? 'Editar Categoria' : 'Nova Categoria'"></h2>
  <form th:action="${categoria.id} != null ? @{|/categorias/${categoria.id}|} : @{/categorias}" method="post" class="row g-3">
    <div class="col-12">
      <label class="form-label">Nome</label>
      <input class="form-control" th:field="*{nome}" th:object="${categoria}" />
      <div class="text-danger" th:if="${#fields.hasErrors('nome')}" th:errors="*{nome}"></div>
    </div>
    <div class="col-12">
      <button class="btn btn-primary" type="submit">Salvar</button>
      <a class="btn btn-secondary" th:href="@{/categorias}">Cancelar</a>
    </div>
  </form>
</div>
</html>
'@
$profList = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2>Professores</h2>
    <a class="btn btn-success" th:href="@{/professores/new}">Novo Professor</a>
  </div>
  <table class="table table-striped">
    <thead><tr><th>ID</th><th>Nome</th><th>Email</th><th>Imagem</th><th style="width:180px">Ações</th></tr></thead>
    <tbody>
      <tr th:each="p : ${professores}">
        <td th:text="${p.id}">1</td>
        <td th:text="${p.nome}">Nome</td>
        <td th:text="${p.email}">Email</td>
        <td><img th:if="${p.imagem}" th:src="${p.imagem}" alt="img" style="height:48px"></td>
        <td>
          <a class="btn btn-sm btn-primary" th:href="@{|/professores/${p.id}/edit|}">Editar</a>
          <form th:action="@{|/professores/${p.id}/delete|}" method="post" class="d-inline">
            <button class="btn btn-sm btn-danger" onclick="return confirm('Excluir?')">Excluir</button>
          </form>
        </td>
      </tr>
    </tbody>
  </table>
</div>
</html>
'@
$profForm = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <h2 th:text="${professor.id} != null ? 'Editar Professor' : 'Novo Professor'"></h2>
  <form th:action="${professor.id} != null ? @{|/professores/${professor.id}|} : @{/professores}" method="post" class="row g-3" th:object="${professor}">
    <div class="col-md-6">
      <label class="form-label">Nome</label>
      <input class="form-control" th:field="*{nome}" />
      <div class="text-danger" th:if="${#fields.hasErrors('nome')}" th:errors="*{nome}"></div>
    </div>
    <div class="col-md-6">
      <label class="form-label">Email</label>
      <input class="form-control" th:field="*{email}" />
      <div class="text-danger" th:if="${#fields.hasErrors('email')}" th:errors="*{email}"></div>
    </div>
    <div class="col-md-12">
      <label class="form-label">Imagem (URL)</label>
      <input class="form-control" th:field="*{imagem}" />
    </div>
    <div class="col-12">
      <button class="btn btn-primary" type="submit">Salvar</button>
      <a class="btn btn-secondary" th:href="@{/professores}">Cancelar</a>
    </div>
  </form>
</div>
</html>
'@
$cursosList = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2>Cursos</h2>
    <a class="btn btn-success" th:href="@{/cursos/new}">Novo Curso</a>
  </div>

  <form class="mb-3">
    <div class="input-group">
      <label class="input-group-text" for="categoriaId">Categoria</label>
      <select class="form-select" id="categoriaId" name="categoriaId" onchange="this.form.submit()">
        <option th:selected="${categoriaSelecionada == null}" value="">Todas</option>
        <option th:each="c : ${categorias}" th:value="${c.id}" th:text="${c.nome}" th:selected="${c.id == categoriaSelecionada}"></option>
      </select>
    </div>
  </form>

  <div class="row row-cols-1 row-cols-md-3 g-3">
    <div class="col" th:each="curso : ${cursos}">
      <div class="card h-100">
        <img th:if="${curso.imagem}" th:src="${curso.imagem}" class="card-img-top" alt="imagem">
        <div class="card-body">
          <h5 class="card-title" th:text="${curso.nome}">Nome</h5>
          <p class="card-text" th:text="${#strings.abbreviate(curso.descricao, 160)}">Descrição</p>
          <a class="btn btn-primary" th:href="@{|/cursos/${curso.id}|}">Ver detalhes</a>
        </div>
      </div>
    </div>
  </div>
</div>
</html>
'@
$cursosForm = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <h2 th:text="${curso.id} != null ? 'Editar Curso' : 'Novo Curso'"></h2>
  <form th:action="${curso.id} != null ? @{|/cursos/${curso.id}|} : @{/cursos}" method="post" class="row g-3" th:object="${curso}">
    <div class="col-md-6">
      <label class="form-label">Nome</label>
      <input class="form-control" th:field="*{nome}" />
      <div class="text-danger" th:if="${#fields.hasErrors('nome')}" th:errors="*{nome}"></div>
    </div>
    <div class="col-md-6">
      <label class="form-label">Imagem (URL)</label>
      <input class="form-control" th:field="*{imagem}" />
    </div>
    <div class="col-12">
      <label class="form-label">Descrição</label>
      <textarea class="form-control" rows="4" th:field="*{descricao}"></textarea>
    </div>
    <div class="col-md-6">
      <label class="form-label">Data Início</label>
      <input class="form-control" type="date" name="dataInicio" th:value="${curso.dataInicio}" />
    </div>
    <div class="col-md-6">
      <label class="form-label">Data Final</label>
      <input class="form-control" type="date" name="dataFinal" th:value="${curso.dataFinal}" />
    </div>
    <div class="col-md-6">
      <label class="form-label">Categoria</label>
      <select class="form-select" th:field="*{categoria}">
        <option th:each="c : ${categorias}" th:value="${c}" th:text="${c.nome}"></option>
      </select>
    </div>
    <div class="col-md-6">
      <label class="form-label">Professor</label>
      <select class="form-select" th:field="*{professor}">
        <option th:each="p : ${professores}" th:value="${p}" th:text="${p.nome}"></option>
      </select>
    </div>
    <div class="col-12">
      <button class="btn btn-primary" type="submit">Salvar</button>
      <a class="btn btn-secondary" th:href="@{/cursos}">Cancelar</a>
    </div>
  </form>
</div>
</html>
'@
$cursosDetails = @'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:replace="fragments :: content">
<div>
  <div class="row">
    <div class="col-md-6">
      <img class="img-fluid rounded" th:if="${curso.imagem}" th:src="${curso.imagem}" alt="imagem">
    </div>
    <div class="col-md-6">
      <h2 th:text="${curso.nome}">Nome</h2>
      <p><strong>Categoria:</strong> <span th:text="${curso.categoria.nome}"></span></p>
      <p><strong>Professor:</strong> <span th:text="${curso.professor.nome}"></span></p>
      <p><strong>Período:</strong> <span th:text="${curso.dataInicio}"></span> a <span th:text="${curso.dataFinal}"></span></p>
      <p th:text="${curso.descricao}">Descrição</p>
      <div class="mt-3">
        <a class="btn btn-secondary" th:href="@{/cursos}">Voltar</a>
        <a class="btn btn-primary" th:href="@{|/cursos/${curso.id}/edit|}">Editar</a>
        <form th:action="@{|/cursos/${curso.id}/delete|}" method="post" class="d-inline">
          <button class="btn btn-danger" onclick="return confirm('Excluir?')">Excluir</button>
        </form>
      </div>
    </div>
  </div>
</div>
</html>
'@
$styleCss = @'
.card-img-top { object-fit: cover; height: 180px; }
'@
# Write all files
$p = Join-Path $ProjectDir "pom.xml"
Set-Content -LiteralPath $p -Value $pomXml -Encoding UTF8

$appPropsPath = Join-Path $srcRes "application.properties"
Set-Content -LiteralPath $appPropsPath -Value $appProps -Encoding UTF8

Set-Content -LiteralPath (Join-Path $srcJava "entity\Categoria.java")   -Value $categoria -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "entity\Professor.java")   -Value $professor -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "entity\Curso.java")       -Value $curso -Encoding UTF8

Set-Content -LiteralPath (Join-Path $srcJava "repository\CategoriaRepository.java") -Value $repoCategoria -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "repository\ProfessorRepository.java") -Value $repoProfessor -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "repository\CursoRepository.java")     -Value $repoCurso -Encoding UTF8

Set-Content -LiteralPath (Join-Path $srcJava "controller\HomeController.java")      -Value $homeController -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "controller\CategoriaController.java") -Value $categoriaController -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "controller\ProfessorController.java") -Value $professorController -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcJava "controller\CursoController.java")     -Value $cursoController -Encoding UTF8

Set-Content -LiteralPath (Join-Path $srcRes "templates\fragments.html")             -Value $fragments -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\index.html")                 -Value $indexTpl -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\categorias\list.html")       -Value $catList -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\categorias\form.html")       -Value $catForm -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\professores\list.html")      -Value $profList -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\professores\form.html")      -Value $profForm -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\cursos\list.html")           -Value $cursosList -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\cursos\form.html")           -Value $cursosForm -Encoding UTF8
Set-Content -LiteralPath (Join-Path $srcRes "templates\cursos\details.html")        -Value $cursosDetails -Encoding UTF8

Set-Content -LiteralPath (Join-Path $srcRes "static\css\style.css")                 -Value $styleCss -Encoding UTF8

Write-Host ""
Write-Host "Arquivos gerados com sucesso."
Write-Host "Para executar:"
Write-Host "  .\mvnw clean spring-boot:run"
Write-Host "Abra http://localhost:8080 e o console H2 em /h2"
