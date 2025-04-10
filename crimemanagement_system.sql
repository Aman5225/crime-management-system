use crimemanagement_system
create TABLE Crime ( 
    CrimeID INT PRIMARY KEY, 
    IncidentType VARCHAR(255), 
    IncidentDate DATE, 
    Location VARCHAR(255), 
    Description TEXT, 
    Status VARCHAR(20) 
);
CREATE TABLE Victim ( 
    VictimID INT PRIMARY KEY, 
    CrimeID INT, 
    Name VARCHAR(255), 
    ContactInfo VARCHAR(255), 
    Injuries VARCHAR(255), 
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID) 
); 
CREATE TABLE Suspect ( 
    SuspectID INT PRIMARY KEY, 
    CrimeID INT, 
    Name VARCHAR(255), 
    Description TEXT, 
    CriminalHistory TEXT, 
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID) 
); 

INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status) 
VALUES 
    (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'), 
    (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under 
Investigation'), 
    (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries) 
VALUES 
    (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'), 
    (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'), 
    (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None'); 
    
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory) 
VALUES 
(1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'), 
(2, 2, 'Unknown', 'Investigation ongoing', NULL), 
(3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests'); 

alter table victim add column age int;
alter table suspect add column age  int;

update victim set age = 30 where victimid =1;
update victim set age = 28 where victimid =2;
update victim set age = 22 where victimid =3;

update suspect set age = 26 where suspectid =1;
update suspect set age = 35 where suspectid =2;
update suspect set age = 24 where suspectid =3;

-- 1.Select all open incidents.
select * from crime where status = 'Open';

-- 2.Find the total number of incidents. 
select count(crimeid) as total_incidents
from crime;

-- 3.List all unique incident types.
select distinct incidenttype
from crime;

-- 4.Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.
select *
from crime
where incidentdate between '2023-09-01' and '2023-09-10';

-- 5.List persons involved in incidents in descending order of age. 
select name,age,'victim' as role from victim
union
select name,age,'suspect' as role from suspect
order by age desc;

-- 6.Find the average age of persons involved in incidents.
select avg(age) as Avgage
from(
select age from victim
union all
select age from suspect)
as avgallperson;

-- 7. List incident types and their counts, only for open cases.
select incidenttype,count(incidenttype) as totalopencases
from crime 
where status = 'open'
group by incidenttype

-- 8.Find persons with names containing 'Doe'. 
select name
from(
  select name from victim
  union 
  select name from suspect) as namedoe
where name like '%doe%'

-- 9.Retrieve the names of persons involved in open cases and closed cases.
select v.name,c.status
from victim v,crime c
where v.crimeid=c.crimeid and  c.status in ('open','closed')
union
select s.name,c.status
from suspect s,crime c
where s.crimeid=c.crimeid and c.status in ('open','closed');

-- 10.List incident types where there are persons aged 30 or 35 involved. 
select v.name,incidenttype,v.age,'victim'as role from crime c
join victim v on c.crimeid = v.crimeid
where age in (30,35)
union
select s.name,incidenttype,s.age,'suspect'as role from crime c 
join suspect s on c.crimeid = s.crimeid
where age in (30,35);

-- 11.Find persons involved in incidents of the same type as 'Robbery'.
select v.name,incidenttype,'victim'as role from crime c
join victim v on c.crimeid = v.crimeid
where incidenttype = 'robbery'
union
select s.name,incidenttype,'suspect'as role from crime c 
join suspect s on c.crimeid = s.crimeid
where incidenttype = 'robbery';

-- 12.List incident types with more than one open case. 
select incidenttype,count(*) as totalopencases 
from crime 
where status ='open'
group by incidenttype
having totalopencases > 1
/* their is no incident types with more than one open case in the given data thus we have a
empty output*/ 


/*13.List all incidents with suspects whose names also appear
 as victims in other incidents*/
select c.*
from crime c,suspect s 
where c.crimeid=s.crimeid and s.name in (select name from victim);
-- or
select *
from crime c
join suspect s on c.crimeid=s.crimeid where s.name in (select name from victim);
-- no suspect name appears as victim in other incidents 

-- 14.Retrieve all incidents along with victim and suspect details.
select c.*,  v.Name as Victim , v.Age , v.Injuries,
  s.Name as Suspect , s.Age , s.CriminalHistory
from crime c
left join victim v on c.crimeid=v.crimeid
left join suspect s on c.crimeid=s.crimeid

-- 15.Find incidents where the suspect is older than any victim.
select * from crime c
join suspect s on c.crimeid=s.crimeid
where s.age>(select v.age from victim v
	where c.crimeid=v.crimeid);
    
    
-- 16.Find suspects involved in multiple incidents: 
select name ,count(*) as totalincidents
from suspect
group by name
having totalincidents > 1;
-- no suspect is involved in multiple incidents 


-- 17.List incidents with no suspects involved.
select c.* from crime c
left join suspect s on c.crimeid=s.crimeid
where s.crimeid is null
-- every incident has a suspect even the homicide has a suspect with age and description-

/*18.List all cases where at least one incident is of type 'Homicide' and all other 
incidents are of type 'Robbery'. */
select *
from crime
where incidenttype in ('homicide','robbery')
and exists (
select crimeid from crime
where incidenttype = 'homicide')
and not exists (
select crimeid from crime
where incidenttype not in ('homicide','robbery'));

/*19.Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if 
there are none. */
select c.crimeid, c.incidenttype, ifnull(s.name, 'no suspect') as suspectname
from crime c
left join suspect s on c.crimeid = s.crimeid;

-- 20.List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault' 
select s.name,c.incidenttype from suspect s
join crime c on c.crimeid=s.crimeid
where incidenttype in ('Robbery','Assault');



