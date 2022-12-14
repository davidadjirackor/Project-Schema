-- create tables
create table projects (
    id                             number generated by default on null as identity 
                                   constraint projects_id_pk primary key,
    name                           varchar2(255 char) not null,
    owner                          varchar2(4000 char),
    created                        date not null,
    created_by                     varchar2(255 char) not null,
    updated                        date not null,
    updated_by                     varchar2(255 char) not null
)
;

create table milestones (
    id                             number generated by default on null as identity 
                                   constraint milestones_id_pk primary key,
    project_id                     number
                                   constraint milestones_project_id_fk
                                   references projects on delete cascade,
    name                           varchar2(255 char) not null,
    status                         varchar2(9 char) constraint milestones_status_ck
                                   check (status in ('OPEN','COMPLETED','CLOSED')),
    owner                          varchar2(4000 char),
    started                        date,
    closed                         date,
    created                        date not null,
    created_by                     varchar2(255 char) not null,
    updated                        date not null,
    updated_by                     varchar2(255 char) not null
)
;

-- table index
create index milestones_i1 on milestones (project_id);

create table links (
    id                             number generated by default on null as identity 
                                   constraint links_id_pk primary key,
    project_id                     number
                                   constraint links_project_id_fk
                                   references projects on delete cascade,
    name                           varchar2(255 char) not null,
    url                            varchar2(4000 char),
    created                        date not null,
    created_by                     varchar2(255 char) not null,
    updated                        date not null,
    updated_by                     varchar2(255 char) not null
)
;

-- table index
create index links_i1 on links (project_id);

create table attachments (
    id                             number generated by default on null as identity 
                                   constraint attachments_id_pk primary key,
    project_id                     number
                                   constraint attachments_project_id_fk
                                   references projects on delete cascade,
    contributed_by                 varchar2(4000 char),
    attachment                     blob,
    attachment_filename            varchar2(512 char),
    attachment_mimetype            varchar2(512 char),
    attachment_charset             varchar2(512 char),
    attachment_lastupd             date,
    created                        date not null,
    created_by                     varchar2(255 char) not null,
    updated                        date not null,
    updated_by                     varchar2(255 char) not null
)
;

-- table index
create index attachments_i1 on attachments (project_id);

create table action_items (
    id                             number generated by default on null as identity 
                                   constraint action_items_id_pk primary key,
    project_id                     number
                                   constraint action_items_project_id_fk
                                   references projects on delete cascade,
    action                         varchar2(4000 char),
    the_desc                       clob,
    owner                          varchar2(4000 char),
    status                         varchar2(9 char) constraint action_items_status_ck
                                   check (status in ('OPEN','COMPLETED','CLOSED')),
    created                        date not null,
    created_by                     varchar2(255 char) not null,
    updated                        date not null,
    updated_by                     varchar2(255 char) not null
)
;

-- table index
create index action_items_i1 on action_items (project_id);


-- triggers
create or replace trigger action_items_biu
    before insert or update 
    on action_items
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end action_items_biu;
/

create or replace trigger projects_biu
    before insert or update 
    on projects
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end projects_biu;
/

create or replace trigger milestones_biu
    before insert or update 
    on milestones
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end milestones_biu;
/

create or replace trigger links_biu
    before insert or update 
    on links
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end links_biu;
/

create or replace trigger attachments_biu
    before insert or update 
    on attachments
    for each row
begin
    if inserting then
        :new.created := sysdate;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end attachments_biu;
/


-- create views
create or replace view project_ms as 
select 
    projects.id                                        project_id,
    projects.name                                      project_name,
    projects.owner                                     project_owner,
    projects.created                                   project_created,
    projects.created_by                                project_created_by,
    projects.updated                                   project_updated,
    projects.updated_by                                project_updated_by,
    milestones.id                                      milestone_id,
    milestones.name                                    milestone_name,
    milestones.status                                  status,
    milestones.owner                                   milestone_owner,
    milestones.started                                 started,
    milestones.closed                                  closed,
    milestones.created                                 milestone_created,
    milestones.created_by                              milestone_created_by,
    milestones.updated                                 milestone_updated,
    milestones.updated_by                              milestone_updated_by
from 
    projects,
    milestones
where
    milestones.project_id(+) = projects.id
/

create or replace view project_ai as 
select 
    projects.id                                        project_id,
    projects.name                                      name,
    projects.owner                                     project_owner,
    projects.created                                   project_created,
    projects.created_by                                project_created_by,
    projects.updated                                   project_updated,
    projects.updated_by                                project_updated_by,
    action_items.id                                    action_item_id,
    action_items.action                                action,
    action_items.the_desc                              the_desc,
    action_items.owner                                 action_item_owner,
    action_items.status                                status,
    action_items.created                               action_item_created,
    action_items.created_by                            action_item_created_by,
    action_items.updated                               action_item_updated,
    action_items.updated_by                            action_item_updated_by
from 
    projects,
    action_items
where
    action_items.project_id(+) = projects.id
/

-- load data
 
insert into projects (
    id,
    name,
    owner
) values (
    1,
    'Tablet Automation Rollout',
    'Gricelda Luebbers'
);

insert into projects (
    id,
    name,
    owner
) values (
    2,
    'Eloqua Marketing Program',
    'Dean Bollich'
);

insert into projects (
    id,
    name,
    owner
) values (
    3,
    'Employee Profile Management',
    'Milo Manoni'
);

insert into projects (
    id,
    name,
    owner
) values (
    4,
    'Selection Development',
    'Laurice Karl'
);

insert into projects (
    id,
    name,
    owner
) values (
    5,
    'Budget Forecasting Upgrade',
    'August Rupel'
);

commit;
 
-- load data
-- load data
 
insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    1,
    4,
    'Tablet Automation Rollout',
    'OPEN',
    'Gricelda Luebbers',
    sysdate - 15,
    sysdate - 92
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    2,
    1,
    'Eloqua Marketing Program',
    'OPEN',
    'Dean Bollich',
    sysdate - 53,
    sysdate - 12
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    3,
    3,
    'Employee Profile Management',
    'OPEN',
    'Milo Manoni',
    sysdate - 2,
    sysdate - 24
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    4,
    2,
    'Selection Development',
    'OPEN',
    'Laurice Karl',
    sysdate - 19,
    sysdate - 15
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    5,
    3,
    'Budget Forecasting Upgrade',
    'CLOSED',
    'August Rupel',
    sysdate - 28,
    sysdate - 31
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    6,
    2,
    'SOA Upgrade',
    'COMPLETED',
    'Salome Guisti',
    sysdate - 74,
    sysdate - 55
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    7,
    3,
    'Onboard German Subsidiary',
    'OPEN',
    'Lovie Ritacco',
    sysdate - 62,
    sysdate - 58
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    8,
    3,
    'Time Assessment',
    'OPEN',
    'Chaya Greczkowski',
    sysdate - 99,
    sysdate - 59
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    9,
    3,
    'Database PDB Consolidation',
    'OPEN',
    'Twila Coolbeth',
    sysdate - 93,
    sysdate - 40
);

insert into milestones (
    id,
    project_id,
    name,
    status,
    owner,
    started,
    closed
) values (
    10,
    2,
    'Zero Downtime Upgrade',
    'OPEN',
    'Carlotta Achenbach',
    sysdate - 63,
    sysdate - 16
);

commit;
 
-- load data
 
insert into links (
    id,
    project_id,
    name,
    url
) values (
    1,
    5,
    'Tablet Automation Rollout',
    'aaac.batavia.com'
);

insert into links (
    id,
    project_id,
    name,
    url
) values (
    2,
    2,
    'Eloqua Marketing Program',
    'aaac.muez.com'
);

insert into links (
    id,
    project_id,
    name,
    url
) values (
    3,
    1,
    'Employee Profile Management',
    'aaae.fustanes.net'
);

insert into links (
    id,
    project_id,
    name,
    url
) values (
    4,
    4,
    'Selection Development',
    'aaac.rumichaca.com'
);

insert into links (
    id,
    project_id,
    name,
    url
) values (
    5,
    5,
    'Budget Forecasting Upgrade',
    'aaab.chatuce.com'
);

commit;
 
-- load data
 
insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    1,
    4,
    'Eu lorem commodo ullamcorper.Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut id nulla ac sapien suscipit tristique ac volutpat risus.Phasellus vitae ligula commodo, dictum lorem sit amet, imperdiet ex. Etiam cursus porttitor tincidunt. Vestibulum ante ipsumprimis in faucibus orci luctus et ultrices posuere cubilia.',
    'x',
    'Gricelda Luebbers',
    'OPEN'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    2,
    5,
    'Elementum sodales. Proin sit amet massa eu lorem commodo ullamcorper.Interdum et malesuada fames.',
    'x',
    'Dean Bollich',
    'COMPLETED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    3,
    4,
    'Pharetra, id mattis risus rhoncus.Cras vulputate porttitor ligula. Nam semper diam suscipit elementum sodales. Proin sit amet massa eu lorem commodo ullamcorper.Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut id nulla.',
    'x',
    'Milo Manoni',
    'CLOSED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    4,
    4,
    'Sapien suscipit tristique ac volutpat risus.Phasellus vitae ligula commodo, dictum lorem sit amet, imperdiet ex. Etiam cursus porttitor tincidunt. Vestibulum ante ipsumprimis.',
    'x',
    'Laurice Karl',
    'OPEN'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    5,
    2,
    'Lorem commodo ullamcorper.Interdum et malesuada fames ac.',
    'x',
    'August Rupel',
    'COMPLETED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    6,
    1,
    'Volutpat risus.Phasellus vitae ligula commodo, dictum lorem sit amet, imperdiet ex. Etiam cursus porttitor tincidunt. Vestibulum ante ipsumprimis in faucibus orci luctus et ultrices posuere cubilia Curae; Proin vulputate placerat pellentesque. Proin viverra lacinialectus, quis consectetur mi venenatis nec. Donec convallis sollicitudin elementum. Nulla facilisi. In.',
    'x',
    'Salome Guisti',
    'CLOSED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    7,
    5,
    'In massa pharetra, id mattis risus rhoncus.Cras vulputate porttitor ligula. Nam semper diam suscipit elementum sodales. Proin sit amet massa eu lorem.',
    'x',
    'Lovie Ritacco',
    'OPEN'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    8,
    3,
    'Ligula. Nam semper diam suscipit elementum sodales. Proin.',
    'x',
    'Chaya Greczkowski',
    'COMPLETED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    9,
    4,
    'Mattis risus rhoncus.Cras vulputate porttitor ligula. Nam semper diam suscipit elementum sodales. Proin sit amet massa eu lorem commodo ullamcorper.Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut id nulla ac sapien suscipit tristique ac volutpat risus.Phasellus vitae ligula commodo, dictum lorem sit amet, imperdiet ex. Etiam cursus porttitor tincidunt. Vestibulum ante.',
    'x',
    'Twila Coolbeth',
    'CLOSED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    10,
    1,
    'Mi venenatis nec. Donec convallis sollicitudin elementum. Nulla facilisi. In posuere blandit leoeget malesuada. Vivamus efficitur ipsum tellus, quis posuere mi maximus vitae. Quisque tortor odio, feugiat eget sagittisvel, pretium ut metus. Duis et commodo arcu.',
    'x',
    'Carlotta Achenbach',
    'OPEN'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    11,
    3,
    'Tristique ac volutpat risus.Phasellus vitae ligula commodo, dictum lorem sit amet, imperdiet ex. Etiam cursus porttitor tincidunt. Vestibulum ante ipsumprimis in faucibus orci luctus et ultrices posuere cubilia Curae; Proin vulputate placerat pellentesque.',
    'x',
    'Jeraldine Audet',
    'COMPLETED'
);

insert into action_items (
    id,
    project_id,
    action,
    the_desc,
    owner,
    status
) values (
    12,
    2,
    'Massa eu lorem commodo ullamcorper.Interdum.',
    'x',
    'August Arouri',
    'CLOSED'
);

commit;
 
 
-- Generated by Quick SQL Saturday August 06, 2022  02:49:07
 
/*
#apex: true, auditcols: true 
projects /insert 5 
    name /nn 
    owner 
    milestones /insert 10 
       name /nn
       status /check open completed closed /values open, open, open, open, closed, completed 
       owner 
       started date 
       closed date 
    links /insert 5 
       name  /nn
       url 
    attachments 
       contributed by 
       attachment file 
    action items /insert 12 
       action 
       desc clob 
       owner 
       status /check open completed closed 
 
view project_ms projects milestones 
view project_ai projects action_items

# settings = { semantics: "CHAR", auditCols: true, language: "EN", APEX: true }
*/
