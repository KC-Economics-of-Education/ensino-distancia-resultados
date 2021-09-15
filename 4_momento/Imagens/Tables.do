/* Dofile: build_dataset_3 */
	
/* Imports and cleans raw data from the second wave of teacher questionnaires
	on distance learning. */
*-------------------------------------------------------------------------------
* ROOT
return clear
capture project, doinfo
if (_rc==0 & !mi(r(pname))) global root `r(pdir)'
else {  // running directly
    if ("${root_ensino_distancia}"=="") do `"`c(sysdir_personal)'profile.do"'
    do "${root_ensino_distancia}/code/set_environment.do"
}

* GLOBALS
global raw "${root}/data/raw"
global derived "${root}/data/derived"
global scratch "${root}/scratch"
global code "${root}/code"
global git_page "$code/clean_data_4/Git_Page"

* DIRECTORIES
cap mkdir "$derived"
cap mkdir "$scratch"

* PARAMETERS

*------------------------------------------------------------------------------------

* Building dataset
// Save and read raw data
import excel "$raw\raw_data_4.xlsx", firstrow

cap drop Jardim_infancia primeirociclo2ciclo terceirociclosec 
replace Assumindoquenãoexistirãonovo="Todo o ano letivo" if Assumindoquenãoexistirãonovo=="Mais que um ano letivo"
replace Assumindoquenãoexistirãonovo="Todo ou mais que um ano letivo" if Assumindoquenãoexistirãonovo=="Todo o ano letivo"
gen Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo, 2º Ciclo"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo, 2º Ciclo, 3º Ciclo"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo, 2º Ciclo, 3º Ciclo, Ensino Secundário"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo, 2º Ciclo, Ensino Secundário"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo, Ensino Secundário"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 1º Ciclo, 3º Ciclo"
replace Jardim_infancia=1 if Queciclosdeensinoseencont=="Jardim de Infância, 2º Ciclo"
gen primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="1º Ciclo"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="2º Ciclo"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo, 3º Ciclo"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo, 3º Ciclo, Ensino Secundário"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo, Ensino Secundário"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="1º Ciclo, 3º Ciclo"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="2º Ciclo, 3º Ciclo"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="2º Ciclo, Ensino Secundário"
replace primeirociclo2ciclo=1 if Queciclosdeensinoseencont=="2º Ciclo, 3º Ciclo, Ensino Secundário"
gen terceirociclosec=1 if Queciclosdeensinoseencont=="3º Ciclo"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="3º Ciclo, Ensino Secundário"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="Ensino Secundário"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo, 3º Ciclo"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo, 3º Ciclo, Ensino Secundário"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="1º Ciclo, 2º Ciclo, Ensino Secundário"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="1º Ciclo, 3º Ciclo"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="2º Ciclo, 3º Ciclo"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="2º Ciclo, Ensino Secundário"
replace terceirociclosec=1 if Queciclosdeensinoseencont=="2º Ciclo, 3º Ciclo, Ensino Secundário"

gen cycle="3º Ciclo + Secundário" if terceirociclosec==1
replace cycle="1º + 2º Ciclos" if primeirociclo2ciclo==1

encode Assumindoquenãoexistirãonovo, gen(recup)
replace recup = 0 if recup == 4
replace recup = 4 if recup == 2
replace recup = 2 if recup == 3
replace recup = 3 if recup == 1
replace recup = 1 if recup == 0
label define recup 1 "Nenhum" 2 "< 6 Semanas" 3 "1 Período" 4 "2 Período" 5 ">= 1 Ano Letivo", replace
label values recup recup

encode Equantosdosseusalunosdoano, gen(alunos)
replace alunos = 0 if alunos == 4
replace alunos = 4 if alunos == 2
replace alunos = 2 if alunos == 3
replace alunos = 3 if alunos == 1
replace alunos = 1 if alunos == 0
label define alunos 1 "Nenhum" 2 "Um quarto" 3 "Metade" 4 "Três quartos" 5 "Todos", replace
label values alunos alunos

label define Numaescalade1a7considera 1 "Nada" 2 "" 3 "" 4 "" 5 "" 6 "" 7 "Muito", replace
label values Numaescalade1a7considera Numaescalade1a7considera

encode AEscolaondelecionouamaiorp, gen(pub_priv)

encode cycle, gen(cycle1)
drop cycle
rename cycle1 cycle
gen pub = 1 if pub_priv == 2
gen priv = 1 if pub_priv == 1
gen ciclo_1 = 1 if Queciclosdeensinoseencont == "1º Ciclo"
gen ciclo_2 = 1 if Queciclosdeensinoseencont == "2º Ciclo"
gen ciclo_3 = 1 if Queciclosdeensinoseencont == "3º Ciclo"
gen ciclo_4 = 1 if Queciclosdeensinoseencont == "Ensino Secundário"
gen ciclo = 1 if ciclo_1 == 1
replace ciclo = 1 if ciclo_2 == 1
replace ciclo = 1 if ciclo_3 == 1
replace ciclo = 1 if ciclo_4 == 1

// Sample Restriction

drop if Aceitoparticiparnesteinquérit == "Não"
drop if _n > 719
drop if missing(cycle)

// Tables

tab Assumindoquenãoexistirãonovo AEscolaondelecionouamaiorp, col
tab Assumindoquenãoexistirãonovo if primeirociclo2ciclo==1
tab Assumindoquenãoexistirãonovo if terceirociclosec==1

tab Equantosdosseusalunosdoano AEscolaondelecionouamaiorp, col
tab Equantosdosseusalunosdoano if primeirociclo2ciclo==1
tab Equantosdosseusalunosdoano if terceirociclosec==1

sum Numaescalade1a7considera
sum Numaescalade1a7considera if primeirociclo2ciclo==1
sum Numaescalade1a7considera if terceirociclosec==1

// Graphs

qui: sum recup, detail
graph hbar (percent), asyvars over(recup) title("Assumindo que não existirão novos encerramentos das escolas no próximo ano letivo," "prevejo que, em média, a recuperação das aprendizagens dos meus alunos do ano letivo 2020/21 irá demorar:", span size(small)) ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1))
graph export "$git_page/recuperacao_1.png", replace

sum recup, detail
graph hbar (percent) pub priv, asyvars over(recup) ///
	title("Assumindo que não existirão novos encerramentos das escolas no próximo ano letivo," "prevejo que, em média, a recuperação das aprendizagens dos meus alunos do ano letivo 2020/21 irá demorar:", span size(small)) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "Público" 2 "Privado")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/recuperacao_2.png", replace

qui: sum recup, detail
graph hbar (percent) primeirociclo2ciclo terceirociclosec, asyvars over(recup) ///
	title("Assumindo que não existirão novos encerramentos das escolas no próximo ano letivo," "prevejo que, em média, a recuperação das aprendizagens dos meus alunos do ano letivo 2020/21 irá demorar:", span size(small)) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "1º + 2º Ciclos" 2 "3º Ciclo + Secundário")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/recuperacao_3.png", replace

qui: sum recup, detail
graph hbar (percent) pub priv, asyvars over(recup) by(cycle) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "Público" 2 "Privado")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/recuperacao_4.png", replace

qui: sum alunos, detail
graph hbar (percent), asyvars over(alunos) title("E quantos dos seus alunos do ano letivo 2020/21 pensa que irão" "recuperar TOTALMENTE os atrasos nas aprendizagens DURANTE O PRÓXIMO ANO LETIVO?", span size(small)) ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1))
graph export "$git_page/alunos_1.png", replace

qui: sum alunos, detail
graph hbar (percent) pub priv, asyvars over(alunos) ///
	title("E quantos dos seus alunos do ano letivo 2020/21 pensa que irão" "recuperar TOTALMENTE os atrasos nas aprendizagens DURANTE O PRÓXIMO ANO LETIVO?", span size(small)) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "Público" 2 "Privado")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/alunos_2.png", replace

qui: sum alunos, detail
graph hbar (percent) primeirociclo2ciclo terceirociclosec, asyvars over(alunos) ///
	title("E quantos dos seus alunos do ano letivo 2020/21 pensa que irão" "recuperar TOTALMENTE os atrasos nas aprendizagens DURANTE O PRÓXIMO ANO LETIVO?", span size(small)) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "1º + 2º Ciclos" 2 "3º Ciclo + Secundário")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/alunos_3.png", replace

qui: sum alunos, detail
graph hbar (percent) pub priv, asyvars over(alunos) by(cycle) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "Público" 2 "Privado")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/alunos_4.png", replace

qui: sum Numaescalade1a7considera, detail
graph bar (percent), asyvars over(Numaescalade1a7considera) title("Numa escala de 1 a 7, considera que o Plano de Recuperação de Aprendizagens apresentado" "pelo Ministério da Educação (Plano 21|23 Escola+) irá contribuir para recuperar" "as aprendizagens dos seus alunos?", span size(small)) ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1))
graph export "$git_page/pra_1.png", replace

qui: sum Numaescalade1a7considera, detail
graph bar (percent) primeirociclo2ciclo terceirociclosec, asyvars over(Numaescalade1a7considera) ///
	title("Numa escala de 1 a 7, considera que o Plano de Recuperação de Aprendizagens apresentado" "pelo Ministério da Educação (Plano 21|23 Escola+) irá contribuir para recuperar" "as aprendizagens dos seus alunos?", span size(small)) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	yvar(relabel(1 "1º + 2º Ciclos" 2 "3º Ciclo + Secundário")) bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/pra_2.png", replace

// Caracterização da Amostra

qui: sum pub_priv, detail
graph hbar (percent) , asyvars over(pub_priv) ///
	ytitle(% Professores (N = `r(N)'), size(small)) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	ylabel(, nogrid) legend(pos(6) rows(1)) ///
	bar(2, fcolor(none) lcolor(black)) bar(1, color(teal%50))
graph export "$git_page/carac_1.png", replace

qui: gen sum_ciclos = ciclo_1 + ciclo_2 + ciclo_3 + ciclo_4
qui: gen ciclo_unico = (sum_ciclos == 1)*100
qui: sum ciclo_unico
local multi_ciclos =100 - `r(mean)'
local multi_ciclos: di %3.0f `multi_ciclos'
forvalues i=1/4 {
replace ciclo_`i' = ciclo_`i'*100
}
qui: count if ciclo_1 == 0
local n = `r(N)'

graph bar ciclo_1 ciclo_2 ciclo_3 ciclo_4, ///
	ytitle(% Professores (N = `n')) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	legend( ///
	order(1 "1º Ciclo" 2 "2º Ciclo" 3 "3º Ciclo" 4 "Ensino Secundário") ///
	rows(1) position(6) ///
	) ///
	note(Nota: A soma das colunas em cada tipo de ensino é superior a 100% porque `multi_ciclos'% dos professores leciona em mais de um ciclo de ensino., ///
	size(vsmall))
graph export "$git_page/carac_2.png", replace

graph bar ciclo_1 ciclo_2 ciclo_3 ciclo_4, over(pub_priv) ///
	ytitle(% Professores (N = `n')) ///
	bargap(5) intensity(*.8) blab(bar, position(outside) format(%9.1f)) ///
	legend( ///
	order(1 "1º Ciclo" 2 "2º Ciclo" 3 "3º Ciclo" 4 "Ensino Secundário") ///
	rows(1) position(6) ///
	) ///
	note(Nota: A soma das colunas em cada tipo de ensino é superior a 100% porque `multi_ciclos'% dos professores leciona em mais de um ciclo de ensino., ///
	size(vsmall))
graph export "$git_page/carac_3.png", replace