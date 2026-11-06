
workspace "Gestão de Aprendizagem e Estágios UniSenai" {

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

        estagios.api.perfil -> estagios.banco "Consulta competências" "SQL"
        estagios.api.vagas -> estagios.banco "Consulta vagas" "SQL"
        estagios.api.match -> estagios.api.perfil "Obtém competências"
        estagios.api.match -> estagios.api.vagas "Obtém requisitos"
        estagios.api.candidaturas -> estagios.banco "Registra candidaturas" "SQL"
    }

    views {
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
