workspace "UniSenai - Grupo 6" "Match entre competências de estudantes e requisitos de vagas industriais." {
    model {
        estudante = person "Estudante" "Consulta vagas de estágio compatíveis."

        unisenai = softwareSystem "Gestão de Aprendizagem e Estágios UniSenai" {
            portal = container "Portal UniSenai" "Recebe a consulta e apresenta os resultados."

            api = container "API de Estágios" "Processa a consulta de vagas compatíveis." {
                match = component "Serviço de Match" "Para cada vaga, compara os níveis do perfil com os mínimos exigidos. Competência ausente recebe nível zero. Rejeita a vaga se algum obrigatório estiver abaixo do mínimo. Nas elegíveis, calcula a aderência e registra os desejáveis não atendidos."
                perfis = component "Repositório de Perfis" "Consulta competências e níveis do estudante."
                vagas = component "Repositório de Vagas" "Consulta vagas abertas e seus requisitos."
            }
        }

        estudante -> portal "Consulta vagas compatíveis"
        portal -> estudante "Apresenta o resultado da consulta"
        portal -> match "Solicita vagas compatíveis"
        match -> portal "Devolve o resultado do match"
        match -> perfis "Consulta o perfil de competências"
        perfis -> match "Devolve o perfil ou informa sua ausência"
        match -> vagas "Consulta vagas abertas e seus requisitos"
        vagas -> match "Devolve as vagas e os requisitos"
    }

    views {
        dynamic api MatchFluxo "Aderência (%) = 100 × soma dos pesos atendidos ÷ soma de todos os pesos. Cada vaga tem pelo menos um requisito, e todos têm peso positivo." {
            title "Grupo 6 - Match de vagas industriais"
            estudante -> portal "Consulta vagas compatíveis"
            portal -> match "conciliarVagas(idEstudante)"
            match -> perfis "buscarPerfil(idEstudante)"
            perfis -> match "Devolve competências e níveis ou informa a ausência de perfil"
            match -> vagas "Se houver perfil, chama listarVagasAbertasComRequisitos()"
            vagas -> match "Devolve vagas com requisitos obrigatórios e desejáveis, níveis mínimos e pesos"
            match -> portal "Se houver perfil, avalia cada vaga e devolve a lista de elegíveis por aderência, com as lacunas desejáveis. Se faltar perfil, devolve PerfilNaoEncontrado."
            portal -> estudante "Exibe as vagas ou informa que o perfil está indisponível ou que a lista está vazia"
            autoLayout lr
        }
    }
}