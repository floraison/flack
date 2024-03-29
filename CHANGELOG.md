
# CHANGELOG.md


## flack 1.3.0  released 2023-03-29

- GET /pointers?count=true
- GET /executions?count=true
- GET /pointers?exid=net.ntt.finance-
- GET /pointers?dexid=20230310
- GET /executions?exid=net.ntt.finance-
- GET /executions?dexid=20230310
- Add Flack.on_unit_created(unit) callback


## flack 1.2.2  released 2021-04-08

- let #rel fall back on PATH_INFO if no REQUEST_PATH


## flack 1.2.1  released 2021-04-08

- Respond with a proper 500 error when necessary (and dump to $stderr)


## flack 1.2.0  released 2021-03-29

- Simplify links
- Remove dependency on HttpClient gem
- Introduce DELETE /executions/:exid
- Ensure METHS order, stabilize across Ruby versions


## flack 1.0.0  released 2020-11-22

- Leave Sequel dependency to flor


## flack 0.16.1  released 2019-02-05

- Depend on Sequel 5 (Sequel 4 and 5 seem OK)
- GET /executions/:domain
- GET /executions/:domain*
- GET /executions/:domain.*
- GET /messages/:point
- GET /messages/:exid/:point
- GET /messages/:exid
- GET /messages/:id
- GET /executions/:exid
- GET /executions/:id


## flack 0.10.0  released 2017-03-03

## flack 0.10.0  released 2017-03-03

- Flack::App#shutdown (@unit.shutdown)


## flack 0.9.1.1  released 2017-01-31

- Fix relaxed dependency on Flor

## flack 0.9.1  released 2017-01-31

- Relax dependency on Flor


## flack 0.9.0  released 2017-01-30

- Initial release


## flack 0.4.0  released 2016-09-12

- Initial empty release

