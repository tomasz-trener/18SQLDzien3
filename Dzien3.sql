

-- operacje teoriomnogosciowe 

-- union 
-- podaj wszystkich zawodników bez polakow 
select imie, nazwisko
from zawodnicy
except
select imie, nazwisko
from zawodnicy
where kraj = 'pol'

-- tylko polacy i jednoczesnie o wzroscie 175 
select imie, nazwisko
from zawodnicy 
where kraj = 'pol'
intersect
select imie, nazwisko
from zawodnicy 
where wzrost > 175

select imie, nazwisko
from zawodnicy 
where kraj = 'pol'
union 
select imie, nazwisko
from zawodnicy 
where wzrost > 175

-- str 29  zad 55

-- podaj zawodnikow, ktorych wzrost jest drugi co do wielkosci 

select  imie, nazwisko, wzrost
from zawodnicy
order by wzrost desc

select * from zawodnicy order by wzrost desc

select * from zawodnicy 
where wzrost = 
	(select max(wzrost) from
		(select imie, nazwisko, wzrost from zawodnicy 
		except
		select imie, nazwisko, wzrost from
		zawodnicy where wzrost = 
			(select max(wzrost) from zawodnicy)) t)

-- str 31

select imie, nazwisko, wzrost
from zawodnicy 
order by wzrost desc

select imie, nazwisko, len(imie),wzrost, rank() over (order by wzrost desc)
from zawodnicy 	

select * from 
	(select imie, nazwisko,  wzrost, dense_rank() over (order by wzrost desc) r
	from zawodnicy ) t
where r=4

select imie, nazwisko, wzrost, ntile(3) over (order by wzrost)
from zawodnicy 

select imie, nazwisko, wzrost, lag(imie,2) over (order by wzrost)
from zawodnicy 

select imie, nazwisko, wzrost, lead(imie,2) over (order by wzrost)
from zawodnicy 

select imie, nazwisko, wzrost, max(wzrost) over (order by wzrost desc)
from zawodnicy 

select imie, nazwisko, wzrost, 
	avg(convert(decimal,wzrost)) over (order by wzrost desc rows between 1 preceding and 2 following) 
from zawodnicy 

select (181.0+180.0+179.0+178.0)/4 -- 179.5


select imie, nazwisko, wzrost, 
	avg(convert(decimal,wzrost)) over (order by wzrost desc rows between unbounded preceding and 2 following) 
from zawodnicy 


select imie, nazwisko, wzrost, 
	avg(convert(decimal,wzrost)) over (order by wzrost desc rows between unbounded preceding and unbounded following) 
from zawodnicy 


select imie, nazwisko, wzrost, 
	max(convert(decimal,wzrost)) over (order by wzrost rows between unbounded preceding and 0 following) 
from zawodnicy 

select imie, nazwisko, wzrost, 
	max(convert(decimal,wzrost)) over (order by wzrost rows between unbounded preceding and current row) 
from zawodnicy 

-- dla kazdego zawodnika wypisz o ile rozni sie jego wzrost 
-- od wzorstu zawodnika od niego nizszego (wzgledem uporzadkowania po wzroscie)

-- jak¹ funkcjê u¿yjemy ?  u¿yjmy lead albo lag 


select imie, nazwisko,wzrost, wzrost - lag(wzrost,1) over (order by wzrost)
from zawodnicy 


select imie, nazwisko, wzrost , kraj,

 avg(wzrost) over (
	partition by kraj
	order by wzrost rows between unbounded preceding and unbounded following)

from zawodnicy 

-- dla kazdego zawodnika, policz o ile cm rozni sie jego wzrost od sredniego wzrostu z jego kraju 

select imie, nazwisko, wzrost , kraj,
 abs( wzrost - 
	 avg(convert(decimal,wzrost)) over (
		partition by kraj
		order by wzrost rows between unbounded preceding and unbounded following))
from zawodnicy 

select imie, nazwisko, abs(wzrost-sr) [roznica], wzrost, sr 
from
	(select imie, nazwisko, wzrost , kraj,
		 avg(convert(decimal,wzrost)) over (
			partition by kraj
			order by wzrost rows between unbounded preceding and unbounded following) sr
	from zawodnicy ) t 

-- 1) dla kazdego zawodnika wypisz nazwisko zawodnika najcie¿szego z jego kraju 

--2) dla kazdego zawodnika podaj jaka jest róznica w danich pomiedzy data jego urodzin
   -- a data najstraszego zawodnika z jego kraju 


 select imie, nazwisko , waga, last_value(nazwisko) over (partition by kraj order by waga 
		rows between unbounded preceding and unbounded following)
 from zawodnicy

 select imie, nazwisko, data_ur, kraj, abs(datediff(d, data_ur, dn))
 from 
	 (select imie, nazwisko, data_ur,kraj, min(data_ur) over (partition by kraj order by data_ur
										rows between unbounded preceding and unbounded following) dn
	 from zawodnicy ) t

 

 -- dla kazdego zawodnika wypisz polowe roku , w ktorej sie urodzil - ( I polowa , II polowa) 


 select kraj,p, avg(wzrost) from
	 (select imie, nazwisko, data_ur, kraj, iif(month(data_ur) < 7, 'I polowa','II polowa') p, wzrost
	 from zawodnicy) t 
group by kraj, p


-- krok 1: wypisz tylko 3 kolumny: I katergoria, II kategoria , wartoœci do agregacji 
select kraj, iif(month(data_ur) < 7, 'I polowa','II polowa') p, wzrost
from zawodnicy

-- krok 2: 
 -- zrobienie podzapytania i dodanie piovt ,okreœla co i jak agregjemy oraz wskazanie, które kolumny chcemy wyœwietlaæ
select * 
from
	(select kraj, iif(month(data_ur) < 7, 'I polowa','II polowa') p, wzrost
from zawodnicy) t
pivot
(
	avg(wzrost)
	for p in ([I polowa],[II polowa])
) pvt

-- piwot staramy sie w taki sposób tworzyæ aby 
-- kategoria I mo¿e byæ liczna ale kategoria II powinna byæ ograniczona 

	 
	 


	select 10 % 2

select * from
	(select * 
	from
		(select kraj, iif(month(data_ur) < 7, 'I polowa','II polowa') p, iif(month(data_ur) %2 =0,'pz','np') pazystosc, wzrost
	from zawodnicy) t
	pivot
	(
		avg(wzrost)
		for p in ([I polowa],[II polowa])
	) pvt) k
where kraj like '%a%'
order by kraj


-- zrób zestawienie, króre wyœwieli ile razy dana ekpia zawodników startowa³a w danym mieœcie

-- nag³ówki wierszy to bêd¹ kraje
-- nag³ówki kolumn to bêd¹ miasta
-- na przeciêciu liczba startów

select * 
from
	(select kraj,nazwa_miasta, count(*) starty
	from zawodnicy z join uczestnictwa u on z.id_zawodnika = u.id_zawodnika
					 join zawody zw on zw.id_zawodow = u.id_zawodow
					 join skocznie s on s.id_skoczni = zw.id_skoczni
					 join miasta m on m.id_miasta = s.id_miasta
	group by kraj, nazwa_miasta) q
 pivot
 (
	sum(starty)
	for nazwa_miasta in (["Lahti"],["Oberstdorf"],["Zakopane"])
 ) pvt



 -- sql   -> t-sql

 declare @napis varchar(50)
 set @napis = 'ger'

 declare @szukanyWzrost varchar(50)
 set @szukanyWzrost = 178


 select imie, nazwisko , kraj
 from zawodnicy 
 where kraj = @napis


 declare @tekst varchar(max)
 set @tekst = ''

 select @tekst = @tekst + imie + ' ,'
 from zawodnicy 

 select @tekst

 select kraj
 from zawodnicy 
 group by kraj

 -- musimy nauczyæ siê tworzyæ w³asne funkcje 


-- select len(imie), policzBMI(waga,wzrost), Dodaj(4,5) from zawodnicy
go

create function dodawanie(@liczbaA int, @liczbaB int) returns int
as
begin
	declare @wynik int
	set @wynik = @liczbaA + @liczbaB
	return @wynik
end

go 

select dbo.dodawanie(4,5)

select imie, nazwisko, dbo.dodawanie(waga,wzrost)
from zawodnicy 

-- spróbuj stwozryc funkcje BMI, która na na wejœciu bedzie oczekiwaæ : waga i wzrost 

go

create function BMI(@waga decimal(5,2), @wzrost decimal(5,2)) returns decimal(5,2)
as
begin
	declare @wynik decimal(5,2)
	set @wynik = @waga/ power(@wzrost/100,2)
	return @wynik
end
go

drop function bmi

select imie, nazwisko , dbo.bmi(waga,wzrost)
from zawodnicy

-- stwórz funkcje, która na podstawie zadanego na wejœciu id_zawodnika
-- wypisze nazwisko jego trenera 
go
create function jegoTrener(@id int) returns varchar(255)
as
begin

	declare @nazwisko varchar(255)

	select @nazwisko= nazwisko_t
	from zawodnicy z join trenerzy t on z.id_trenera= t.id_trenera
	where id_zawodnika = @id

	return @nazwisko
end
go
select imie, nazwisko, dbo.jegoTrener(id_zawodnika)
from zawodnicy 

go

-- napiszmy funkcje: "jegoZawodnicy", która na wejsciu oczekuje id_trenera
-- i zwraca jako napis liste nazwisk zawodnikow, oddzielon¹ przecinkami 

go
alter function jegoZawodnicy(@id int) returns varchar(max)
as
begin

	declare @nazwiska varchar(255) 
	set @nazwiska =''

	select @nazwiska = @nazwiska + ', ' + nazwisko
	from zawodnicy z join trenerzy t on z.id_trenera = t.id_trenera
	where t.id_trenera =@id
	return substring(@nazwiska,3,len(@nazwiska))
end
go


select imie_t, nazwisko_t, dbo.jegoZawodnicy(id_trenera)
from trenerzy 


declare @i int 
set @i =1 

while @i < 10
begin	
--select @i
	insert into zawodnicy (imie,nazwisko) values ('jan','kowalski' + convert(varchar,@i))
	set @i = @i+1
end

select * from zawodnicy


select 'ala' + convert(varchar, 1)

go
create view ZawBMI
as
select imie, nazwisko , waga/power(wzrost/100.0,2) bmi 
from zawodnicy 

go

insert into zawodnicy (imie, nazwisko) values ('adam','kowalski')


insert into ZawBMI (imie, nazwisko) values ('ola','kowalska')


select * from zawodnicy

select * from zawbmi
go
create view tylkoPolacy
as select imie, nazwisko, kraj from zawodnicy where kraj = 'pol'
go


select * from tylkoPolacy

insert into tylkopolacy values ('adam','nowak','pol')

select * from zawodnicy


select * from zawodnicy


--delete zawodnicy

select *
from zawodnicy where nazwisko like '%kow%'

delete zawodnicy where nazwisko like '%kow%'


select * from zawodnicy 
select * from trenerzy 

delete trenerzy where id_trenera = 5

update zawodnicy set id_trenera = null where id_trenera =4

ALTER TABLE trenerzy
ALTER COLUMN id_trenera int NOT NULL; 


ALTER TABLE trenerzy
ADD PRIMARY KEY (id_trenera); 


ALTER TABLE zawodnicy
ADD FOREIGN KEY (id_trenera) REFERENCES trenerzy(id_trenera) --on delete cascade


-- szkolenia@tomaszles.pl 

  
































 


