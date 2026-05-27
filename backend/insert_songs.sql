-- SQL Script to Seed Songs Table
-- Handles trimmed URLs and inserts metadata into the 'songs' table

INSERT INTO songs (song_name, movie, actor, actress, artist, composer, lyricist, category, image_url, song_url)
VALUES 
('Deewani Mastani', 'Bajirao Mastani', 'Ranveer Singh', 'Deepika Padukone, Priyanka Chopra', 'Shreya Ghoshal, Ganesh Chandanshive, Mujtaba Aziz Naza, Farhan Sabri, Altmash Faridi', 'Sanjay Leela Bhansali', 'Siddharth-Garima', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964122/deewani_mastani_yoyusg.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899769/Deewani_Mastani_-_Bajirao_Mastani_320_Kbps_cvubs7.mp3'),

('Manwa Laage', 'Happy New Year', 'Shah Rukh Khan', 'Deepika Padukone', 'Arijit Singh, Shreya Ghoshal', 'Vishal-Shekhar', 'Irshad Kamil', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964115/manwa_laage_w2yfj3.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899778/Manwa_Laage_-_Happy_New_Year_320_Kbps_vxqzll.mp3'),

('Saudebaazi', 'Aakrosh', 'Ajay Devgn, Akshaye Khanna', 'Bipasha Basu', 'Anupam Amod', 'Pritam', 'Irshad Kamil', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964094/Saudebaazi_Encore_atv45e.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899796/saudebaazi_pgth5l.mp3'),

('Tere Bina', 'Guru', 'Abhishek Bachchan', 'Aishwarya Rai Bachchan', 'A. R. Rahman, Chinmayi Sripaada, Murtuza Khan, Qadir Khan', 'A. R. Rahman', 'Gulzar', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964087/tere_bina_xyjui5.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899820/Tere_Bina_-_Guru_320_Kbps_ypzapd.mp3'),

('Tum Tak', 'Raanjhanaa', 'Dhanush', 'Sonam Kapoor', 'Javed Ali, Keerthi Sagathia, Pooja AV', 'A. R. Rahman', 'Irshad Kamil', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779898640/tum_tak_dbz8mg.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899839/Tum_Tak_-_Raanjhanaa_320_Kbps_uwdwcs.mp3'),

('Until I Found You', '', '', '', 'Stephen Sanchez', 'Stephen Sanchez, Ian Fitchuk', 'Stephen Sanchez, Em Beihold', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964084/Until-I-Found-You-Em-Beihold-Version-English_txl4vd.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962116/Stephen_Sanchez_-_Until_I_Found_You_Official_Video_g6wbap.mp3'),

('What Makes You Beautiful', '', '', '', 'One Direction', 'Rami Yacoub, Carl Falk', 'Savan Kotecha', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964082/whatmakesyoubeautiful_dqfgkh.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962121/One_Direction_-_What_Makes_You_Beautiful_Official_Video_tvupwe.mp3'),

('Perfect', '', '', '', 'Ed Sheeran', 'Ed Sheeran, Steve Mac', 'Ed Sheeran', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964092/Perfect_gcxlvz.jpg', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962131/Ed_Sheeran_-_Perfect_Official_Music_Video_flzpti.mp3'),

('Night Changes', '', '', '', 'One Direction', 'Jamie Scott, Julian Bunetta, John Ryan', 'Jamie Scott, Julian Bunetta, John Ryan', 'Classic', 'https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964097/One_Direction_-_Night_Changes_Single_Cover_wcidw0.png', 'https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962126/One_Direction_-_Night_Changes_onxwms.mp3');
