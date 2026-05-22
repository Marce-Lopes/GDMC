# Perguntas de Entrevista (Prioridade de Negócio + Comportamental) - Stack GDMC

## Objetivo

Avaliar se o entrevistado consegue equilibrar:

- urgência de negócio,
- risco técnico,
- comunicação com stakeholders,
- e execução pragmática em produção.

## Perguntas de Prioridade de Negócio

### 1) Entrega urgente vs desenho ideal

**Pergunta:** O negócio exige solução em 24 horas para reduzir impacto financeiro. Você tem uma solução tecnicamente ideal (2 semanas) e uma solução simples/temporária (1 dia). Como decide?\
**Resposta esperada:**

- Priorizar solução temporária com menor risco operacional para atender urgência.
- Definir guardrails (feature flag, rollback, monitoramento).
- Registrar dívida técnica e abrir plano da solução estrutural.

### 2) Trade-off explícito para o negócio

**Pergunta:** Como você explicaria para área de negócio que a entrega rápida terá limitações técnicas temporárias?\
**Resposta esperada:**

- Comunicar em linguagem de impacto: risco, prazo, benefício imediato e prazo da correção definitiva.
- Alinhar “aceite de risco” com responsáveis de negócio e operação.
- Formalizar critérios de sucesso e gatilhos de rollback.

### 3) Correção mínima segura

**Pergunta:** Diante de incidente em produção, qual critério você usa para definir a “mínima mudança segura” em vez de refatorar tudo?\
**Resposta esperada:**

- Focar no ponto de falha crítico, reduzir escopo da mudança e preservar comportamento atual.
- Evitar mudanças estruturais grandes durante incidente.
- Garantir teste rápido, observabilidade e reversão simples.

### 4) Quando dizer “não” para atalho

**Pergunta:** Em quais situações você não aceitaria uma solução rápida mesmo com pressão do negócio?\
**Resposta esperada:**

- Quando houver risco grave de segurança, compliance, perda de dados ou indisponibilidade ampla.
- Quando não existir rollback viável.
- Quando a solução rápida puder amplificar muito o incidente.

### 5) Plano de duas fases (agora + depois)

**Pergunta:** Proponha um plano em duas fases para uma demanda urgente: Fase 1 (48h) e Fase 2 (2-4 semanas).\
**Resposta esperada:**

- Fase 1: mitigação rápida, controlada por flag, monitorada, com KPI de estabilização.
- Fase 2: solução estrutural (redução de acoplamento, resiliência, testes, documentação).
- Definição de dono, prazo e critérios objetivos de conclusão.

### 6) Priorização com capacidade limitada

**Situações Hipotéticas**
**Pergunta:** Você recebe 10 demandas críticas e só consegue entregar 3 nesta semana. Como prioriza e como comunica o que ficou de fora?\
**Resposta esperada:**

- Priorizar por impacto de negócio, risco operacional e dependências.
- Tornar explícito o que entra e o que sai da semana com justificativa objetiva.
- Negociar prazo/escopo com stakeholders e registrar compromisso para próximo ciclo.

### 7) Mudança brusca de prioridade

**Situações Hipotéticas**
**Pergunta:** No meio da execução, chega uma urgência do negócio que troca a prioridade do dia. Qual seu critério para interromper o que estava fazendo?\
**Resposta esperada:**

- Avaliar impacto imediato (financeiro, cliente, operação, compliance).
- Interromper somente se o novo item superar claramente a prioridade atual.
- Formalizar decisão, comunicar impactos e atualizar plano do time.

### 8) Pressão contínua e saúde do time

**Situações Hipotéticas**
**Pergunta:** Como você evita burnout do time quando a pressão e a urgência viram rotina?\
**Resposta esperada:**

- Limitar WIP, proteger foco e remover trabalho de baixo valor.
- Estabelecer cadência realista, rodízio de incidentes e janelas de recuperação.
- Escalar capacidade/riscos para gestão com dados e não apenas percepção.

### 9) Entrega rápida sem perder confiança

**Situações Hipotéticas**
**Pergunta:** Como você decide entre “solução rápida agora” e “solução correta depois” sem perder confiança do negócio?\
**Resposta esperada:**

- Aplicar abordagem em duas fases: mitigação imediata + correção estrutural com prazo.
- Definir limites claros do paliativo e critérios de saída.
- Comunicar trade-off com transparência e acompanhar por métricas.

### 10) Organização sob backlog estourado

**Situações Hipotéticas**
**Pergunta:** Em cenário de backlog estourado, qual ritual/processo você implementaria já na primeira semana para organizar fluxo e dar previsibilidade?\
**Resposta esperada:**

- Triagem semanal com critérios de priorização claros (impacto x urgência x risco).
- Quadro único de demandas com dono, status e SLA acordado.
- Revisão curta diária de bloqueios + checkpoint semanal com negócio.

## Critérios de Avaliação

- **Prioridade correta:** atende urgência sem negligenciar risco crítico.
- **Pragmatismo:** propõe solução executável no prazo.
- **Gestão de risco:** define monitoramento, rollback e limites claros.
- **Comunicação:** traduz decisão técnica para impacto de negócio.

## Peso por Pergunta

Escala sugerida por pergunta: **0 a 5 pontos**.

### Distribuição de peso (total 100%)

- Q1: 10%
- Q2: 10%
- Q3: 10%
- Q4: 10%
- Q5: 10%
- Q6: 10%
- Q7: 10%
- Q8: 10%
- Q9: 10%
- Q10: 10%

## Rubrica (como dar a nota 0-5)

- **0:** não respondeu ou resposta incorreta.
- **1:** resposta superficial e sem noção de risco.
- **2:** acerta parcialmente, mas sem plano claro.
- **3:** resposta correta no básico, com ações práticas simples.
- **4:** boa priorização com mitigação e comunicação adequada.
- **5:** excelente equilíbrio negócio x técnica, com plano realista e governança.

## Fórmula de Nota Final

- **Nota ponderada por pergunta** = `nota(0-5) * peso(%)`
- **Nota final (0-5)** = `soma das notas ponderadas / 100`
- **Nota final (%)** = `(nota final / 5) * 100`

## Tabela de Avaliação (preenchimento)

| Q         | Foco                         | Peso % | Nota (0-5) | Pontuação ponderada | Observações |
| --------- | ---------------------------- | -----: | ---------: | ------------------: | ----------- |
| 1         | Decisão sob urgência         |     10 |     <br /> |              <br /> | <br />      |
| 2         | Comunicação com negócio      |     10 |     <br /> |              <br /> | <br />      |
| 3         | Escopo mínimo seguro         |     10 |     <br /> |              <br /> | <br />      |
| 4         | Limites do atalho            |     10 |     <br /> |              <br /> | <br />      |
| 5         | Plano agora/depois           |     10 |     <br /> |              <br /> | <br />      |
| 6         | Priorização com capacidade limitada | 10 | <br /> | <br /> | <br /> |
| 7         | Mudança brusca de prioridade |     10 |     <br /> |              <br /> | <br />      |
| 8         | Pressão contínua e saúde do time | 10 | <br /> | <br /> | <br /> |
| 9         | Entrega rápida sem perder confiança | 10 | <br /> | <br /> | <br /> |
| 10        | Organização sob backlog estourado | 10 | <br /> | <br /> | <br /> |
| **Total** | **Prioridade de Negócio**    | **100**|     <br /> |              <br /> | <br />      |

## Classificação sugerida

- **85% a 100%**: forte maturidade para decisões sob pressão.
- **70% a 84%**: bom nível, com pequenos ajustes de priorização.
- **55% a 69%**: intermediário, precisa apoio em gestão de trade-off.
- **Abaixo de 55%**: risco alto em cenários de urgência.
