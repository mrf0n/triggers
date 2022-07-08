CREATE TRIGGER add_citizen ON dbo.person   --https://docs.microsoft.com/ru-ru/sql/t-sql/language-elements/fetch-transact-sql?view=sql-server-ver15
AFTER INSERT
AS
declare
	@id_person int,
	@id_city int
begin
	declare cur cursor for
	select id, city_id 
	from inserted
	
	open cur
	fetch next from cur into @id_person, @id_city
	while @@FETCH_STATUS=0
		begin
		if((select population from city where id=@id_city) < (select max_population from city where id=@id_city))
		update city set population+=1 where id=@id_city
		if((select population from city where id=@id_city) = (select max_population from city where id=@id_city))
		update person set city_id=null where id=@id_person
		fetch next from cur into @id_person, @id_city
		end
	close cur
	deallocate cur
end;

drop trigger add_citizen

create trigger update_cit on person
after update
as declare
	@id_person int,
	@id_old int,
	@id_new int
begin
	declare curs cursor
	for
	select inserted.id, inserted.city_id, deleted.city_id
	from inserted join deleted on inserted.id=deleted.id
	open curs
	fetch next from curs into @id_person,@id_new,@id_old
	while @@FETCH_STATUS=0
	begin
	update city set population-=1 where id=@id_old
	fetch next from curs into @id_person,@id_new,@id_old
	end
	close curs
	deallocate curs

	declare curss cursor
	for
	select inserted.id, inserted.city_id, deleted.city_id
	from inserted join deleted on inserted.id=deleted.id
	open curss
	while @@FETCH_STATUS=0
	begin
	if((select population from city where id=@id_new)<(select max_population from city where id=@id_new))
	update city set population+=1 where id=@id_new
	if((select population from city where id=@id_new)=(select max_population from city where id=@id_new))
	update person set city_id=null where id=@id_person
	fetch next from curss into @id_person,@id_new,@id_old
	end
	close curss
	deallocate curss

end;

create trigger del_citizen on person
after delete
as
declare
@id_city int
begin
	declare cur cursor
	for
	select city_id from deleted
	open cur
	fetch next from cur into @id_city
	while @@FETCH_STATUS=0
	begin
	update city set population-=1 where id=@id_city
	fetch next from cur into @id_city
	end
	close cur
	deallocate cur
end;


drop trigger add_citizen
drop trigger update_cit
drop trigger del_citizen

update person set city_id=3 where id=2
insert into person(id, name, birth_date, city_id, univercity_id) values (4, 'Ленка', 1-07-2001, 2, null)
delete from person where id IN(5)
select * from dbo.person
select * from dbo.city
