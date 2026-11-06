workspace "Gestão de Aprendizagem e Estágios UniSenai" {

    !identifiers hierarchical

    model {
        aluno = person "Aluno" "Consulta oportunidades e realiza candidaturas."
        empresa = person "Empresa" "Cadastra vagas e acompanha candidatos."
        coordenacao = person "Coordenação" "Gerencia estudantes, empresas e oportunidades."

        estagios = softwareSystem "Sistema de Gestão de Estágios UniSenai" {
            frontend = container "Aplicação Web" "Interface utilizada pelos usuários." "React"

            api = container "API Backend" "Responsável pelas regras de negócio." "Node.js / TypeScript" {
                perfil = component "Serviço de Perfil" "Consulta competências dos estudantes." "PerfilService"
                vagas = component "Serviço de Vagas" "Gerencia vagas e requisitos." "VagaService"
                match = component "Serviço de Compatibilidade" "Compara competências e requisitos das vagas." "MatchService"
                candidaturas = component "Serviço de Candidaturas" "Gerencia inscrições dos estudantes." "CandidaturaService"
            }

            banco = container "Banco de Dados" "Armazena estudantes, empresas e vagas." "PostgreSQL" {
                tags "Database"
            }
        }

        aluno -> estagios.frontend "Consulta oportunidades"
        empresa -> estagios.frontend "Gerencia vagas"
        coordenacao -> estagios.frontend "Administra o sistema"

        estagios.frontend -> estagios.api "Envia requisições" "HTTPS/JSON"
        estagios.frontend -> estagios.api.match "Solicita vagas compatíveis" "HTTPS/JSON"

        estagios.api.perfil -> estagios.banco "Consulta competências" "SQL"
        estagios.api.vagas -> estagios.banco "Consulta vagas" "SQL"
        estagios.api.match -> estagios.api.perfil "Obtém competências"
        estagios.api.match -> estagios.api.vagas "Obtém requisitos"
        estagios.api.match -> estagios.api.match "Avalia e ordena as vagas"
        estagios.api.candidaturas -> estagios.banco "Registra candidaturas" "SQL"
    }

    views {
        properties {
            "plantuml.sequenceDiagram" "true"
            "mermaid.sequenceDiagram" "true"
        }

        systemContext estagios "Contexto" {
            include *
            autoLayout lr
        }

        container estagios "Conteineres" {
            include *
            autoLayout lr
        }

        component estagios.api "ComponentesAPI" {
            include *
            autoLayout lr
        }

        dynamic estagios.api "FluxoMatch" {
            title "Grupo 6 - Match de vagas industriais"
            description "Aderência (%) = 100 × soma dos pesos atendidos ÷ soma de todos os pesos. Cada vaga tem pelo menos um requisito, e todos têm peso positivo."
            default

            aluno -> estagios.frontend "Consultar vagas compatíveis"
            estagios.frontend -> estagios.api.match "conciliarVagas(idEstudante)"
            estagios.api.match -> estagios.api.perfil "buscarPerfil(idEstudante)"
            estagios.api.perfil -> estagios.api.match "Retornar competências e níveis ou indicar perfil ausente"
            estagios.api.match -> estagios.api.vagas "[Perfil encontrado] listarVagasAbertasComRequisitos()"
            estagios.api.vagas -> estagios.api.match "[Perfil encontrado] Retornar vagas, níveis mínimos e pesos"
            estagios.api.match -> estagios.api.match "[Para cada vaga] avaliarAderencia(perfil, requisitos). Competência ausente recebe nível zero."
            estagios.api.match -> estagios.api.match "[Obrigatório abaixo do mínimo] Excluir a vaga. [Elegível] Calcular aderência e registrar lacunas."
            estagios.api.match -> estagios.api.match "[Após avaliar as vagas] Ordenar as elegíveis por aderência decrescente"
            estagios.api.match -> estagios.frontend "[Perfil encontrado] Retornar a lista ordenada. [Perfil ausente] Retornar PerfilNaoEncontrado."
            estagios.frontend -> aluno "[Com resultados] Exibir vagas. [Lista vazia] Informar que não há vagas compatíveis. [Perfil ausente] Informar que o perfil está indisponível."

            autoLayout tb
        }

        styles {
            element "Person" {
                shape Person
            }

            element "Database" {
                shape Cylinder
                background #2b78e4
                color #ffffff
            }
        }
    }
}
