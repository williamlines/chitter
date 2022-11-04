TRUNCATE TABLE users, peeps RESTART IDENTITY; 

INSERT INTO users (handle, email, password) VALUES ('adam1', 'adam1@gmail.com', '$2a$12$lK8Xgo79g42LITMQ3ugveeX3PK4ZywMaTOY8WI3kpVlDC46WkrqL.');
INSERT INTO users (handle, email, password) VALUES ('bob2', 'bob2@gmail.com', '$2a$12$/edoUWpvC3f6f2KlPGW29.E8ZAunAgNO1Jw.iQQominWUMPtobZUa');
INSERT INTO users (handle, email, password) VALUES ('clara3', 'clara3@gmail.com', '$2a$12$QvTlZ8oxeMFof5wlsDWXJ.uT0lraNcDsCKbtEnLTLO1HRpeH6Buoi');




INSERT INTO peeps (content, time, user_id) VALUES ('adams first peep', '2022-11-02 12:00:00', '1');
INSERT INTO peeps (content, time, user_id) VALUES ('adams second peep', '2022-11-02 12:30:00', '1');
INSERT INTO peeps (content, time, user_id) VALUES ('bobs first peep', '2022-11-02 14:00:00', '2');
INSERT INTO peeps (content, time, user_id) VALUES ('bobs second peep', '2022-11-03 04:00:00', '2');
INSERT INTO peeps (content, time, user_id) VALUES ('claras first peep', '2022-11-03 15:55:00', '3');
INSERT INTO peeps (content, time, user_id) VALUES ('claras old peep', '2000-01-01 12:00:00', '3');