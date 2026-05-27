package com.musiverse.backend.controller;

import com.musiverse.backend.entity.Song;
import com.musiverse.backend.entity.User;
import com.musiverse.backend.repository.UserRepository;
import com.musiverse.backend.service.SongService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.musiverse.backend.service.CloudinaryService;
import org.springframework.web.multipart.MultipartFile;

import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/songs")
public class SongController {

    private final SongService songService;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;

    public SongController(SongService songService, UserRepository userRepository, CloudinaryService cloudinaryService) {
        this.songService = songService;
        this.userRepository = userRepository;
        this.cloudinaryService = cloudinaryService;
    }

    // =========================
    // SEED DATABASE (Helper Endpoint)
    // =========================
    @GetMapping("/seed")
    public ResponseEntity<?> seedSongs() {
        try {
            // 🧹 Clean up duplicate data from database (if all key fields match)
            List<Song> allSongsBefore = songService.getAllSongs();
            Map<String, List<Song>> groupedSongs = allSongsBefore.stream()
                .collect(java.util.stream.Collectors.groupingBy(s -> 
                    s.getSongName().trim().toLowerCase() + "||" + (s.getArtist() == null ? "" : s.getArtist().trim().toLowerCase())
                ));
            
            int duplicatesDeleted = 0;
            List<User> allUsers = userRepository.findAll();
            for (Map.Entry<String, List<Song>> entry : groupedSongs.entrySet()) {
                List<Song> duplicates = entry.getValue();
                if (duplicates.size() > 1) {
                    // Keep the first one (smallest id), delete others
                    duplicates.sort(java.util.Comparator.comparing(Song::getId));
                    for (int i = 1; i < duplicates.size(); i++) {
                        Song toDelete = duplicates.get(i);
                        // Clean up relationships in other tables first to avoid FK constraint errors
                        for (User user : allUsers) {
                            boolean changed = false;
                            if (user.getLikedSongs().contains(toDelete)) {
                                user.getLikedSongs().remove(toDelete);
                                changed = true;
                            }
                            if (user.getHiddenSongs().contains(toDelete)) {
                                user.getHiddenSongs().remove(toDelete);
                                changed = true;
                            }
                            if (changed) {
                                userRepository.save(user);
                            }
                        }
                        songService.deleteSong(toDelete.getId());
                        duplicatesDeleted++;
                    }
                }
            }

            final int finalDuplicatesDeleted = duplicatesDeleted;

            List<Song> songs = List.of(
                new Song("Deewani Mastani", "Bajirao Mastani", "Ranveer Singh", "Deepika Padukone, Priyanka Chopra", 
                    "Shreya Ghoshal, Ganesh Chandanshive, Mujtaba Aziz Naza, Farhan Sabri, Altmash Faridi", 
                    "Sanjay Leela Bhansali", "Siddharth-Garima", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964122/deewani_mastani_yoyusg.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899769/Deewani_Mastani_-_Bajirao_Mastani_320_Kbps_cvubs7.mp3"),
                
                new Song("Manwa Laage", "Happy New Year", "Shah Rukh Khan", "Deepika Padukone", 
                    "Arijit Singh, Shreya Ghoshal", "Vishal-Shekhar", "Irshad Kamil", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964115/manwa_laage_w2yfj3.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899778/Manwa_Laage_-_Happy_New_Year_320_Kbps_vxqzll.mp3"),
                
                new Song("Saudebaazi", "Aakrosh", "Ajay Devgn, Akshaye Khanna", "Bipasha Basu", 
                    "Anupam Amod", "Pritam", "Irshad Kamil", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964094/Saudebaazi_Encore_atv45e.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899796/saudebaazi_pgth5l.mp3"),
                
                new Song("Tere Bina", "Guru", "Abhishek Bachchan", "Aishwarya Rai Bachchan", 
                    "A. R. Rahman, Chinmayi Sripaada, Murtuza Khan, Qadir Khan", "A. R. Rahman", "Gulzar", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964087/tere_bina_xyjui5.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899820/Tere_Bina_-_Guru_320_Kbps_ypzapd.mp3"),
                
                new Song("Tum Tak", "Raanjhanaa", "Dhanush", "Sonam Kapoor", 
                    "Javed Ali, Keerthi Sagathia, Pooja AV", "A. R. Rahman", "Irshad Kamil", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779898640/tum_tak_dbz8mg.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779899839/Tum_Tak_-_Raanjhanaa_320_Kbps_uwdwcs.mp3"),
                
                new Song("Until I Found You", "", "", "", 
                    "Stephen Sanchez", "Stephen Sanchez, Ian Fitchuk", "Stephen Sanchez, Em Beihold", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964084/Until-I-Found-You-Em-Beihold-Version-English_txl4vd.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962116/Stephen_Sanchez_-_Until_I_Found_You_Official_Video_g6wbap.mp3"),
                
                new Song("What Makes You Beautiful", "", "", "", 
                    "One Direction", "Rami Yacoub, Carl Falk", "Savan Kotecha", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964082/whatmakesyoubeautiful_dqfgkh.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962121/One_Direction_-_What_Makes_You_Beautiful_Official_Video_tvupwe.mp3"),
                
                new Song("Perfect", "", "", "", 
                    "Ed Sheeran", "Ed Sheeran, Steve Mac", "Ed Sheeran", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964092/Perfect_gcxlvz.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962131/Ed_Sheeran_-_Perfect_Official_Music_Video_flzpti.mp3"),
                
                new Song("Night Changes", "", "", "", 
                    "One Direction", "Jamie Scott, Julian Bunetta, John Ryan", "Jamie Scott, Julian Bunetta, John Ryan", "Classic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964097/One_Direction_-_Night_Changes_Single_Cover_wcidw0.png", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962126/One_Direction_-_Night_Changes_onxwms.mp3"),

                new Song("Be Your Light", "The Story of Light EP.2", "N/A", "N/A", 
                    "SHINee", "Andrew Choi, MZMC, Otha 'Vakseen' Davis III", "Kim Eana", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963604/beyourlight_ynrxjm.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961930/Be_Your_Light_%E5%81%B7%E5%81%B7%E8%97%8F%E4%B8%8D%E4%BD%8F_%E9%9B%BB%E8%A6%96%E5%8A%87%E6%8F%92%E6%9B%B2_-_%E9%A6%AC%E4%BC%AF%E9%A8%AB_%E6%BC%AB%E5%A4%A9%E8%8A%B1%E7%93%A3%E5%9C%A8%E6%88%91%E5%80%91%E8%BA%AB%E5%BE%8C_%E8%B7%9F%E9%9A%A8_%E6%98%AF%E5%A6%B3%E6%89%8D_%E8%AE%93_%E9%99%BD%E5%85%89%E8%90%BD%E4%B8%8B%E4%BE%86_%E5%8B%95%E6%85%8B%E6%AD%8C%E8%A9%9E_mght05.mp3"),

                new Song("Can't Get Over You", "BALLADS 1", "N/A", "N/A", 
                    "Joji", "Joji, Clams Casino, Thundercat", "Joji", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963609/Cant_get_over_you_z0xzpl.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961945/-MV-_Paul_Kim_%ED%8F%B4%ED%82%B4_-_Can_t_Get_Over_You_%EC%A2%8B%EC%95%84%ED%95%B4%EC%9A%94_tbvqrd.mp3"),

                new Song("Cupid", "The Beginning: Cupid", "N/A", "N/A", 
                    "FIFTY FIFTY", "Adam von Mentzer, Mac Felländer-Tsai, Louise Udin", "Keena", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963590/cupid_wl4gut.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961896/FIFTY_FIFTY_%ED%94%BC%ED%94%84%ED%8B%B0%ED%94%BC%ED%94%84%ED%8B%B0_-__Cupid__Official_MV_iv0uki.mp3"),

                new Song("Forgetting You", "K-Drama OST", "N/A", "N/A", 
                    "Davichi", "Lee Hae-ri, Kang Min-kyung", "Various", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963593/Forgetting_you_eqoiky.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961883/Forgetting_You_%EA%B7%B8%EB%8C%80%EB%A5%BC_%EC%9E%8A%EB%8A%94%EB%8B%A4%EB%8A%94_%EA%B1%B4_-_Davichi_%EB%8B%A4%EB%B9%84%EC%B9%98_-HAN_ROM_ENG_COLOR_CODED_LYRICS-_ko5brj.mp3"),

                new Song("Here Always", "Hometown Cha-Cha-Cha OST Part 3", "Kim Seon-ho", "Shin Min-a", 
                    "Seungmin (Stray Kids)", "Park Se-joon, Seo Dong-hwan", "Kim Na-young", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963601/Here_always_mfgqlx.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961959/-Hometown_Chachacha_OST_Part_7_ENGSUB-__Here_Always__by_Stray_Kids_%EC%8A%B9%EB%AF%BC_FMV_-1x14_bmly4l.mp3"),

                new Song("I'm Missing You", "True Beauty OST", "Cha Eun-woo", "Moon Ga-young", 
                    "Sunjae", "DOKO", "DOKO", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963595/I_m_missing_you_peal1q.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961877/Sunjae_%EC%84%A0%EC%9E%AC__I_m_Missing_You__-OST-_%EC%97%AC%EC%8B%A0%EA%B0%95%EB%A6%BC_OST_Part_4_-MV-_jgprfu.mp3"),

                new Song("Last Chance", "The Moon That Embraces the Sun OST", "Kim Soo-hyun", "Han Ga-in", 
                    "K.Will", "Kim Do-hoon", "Various", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963599/Last_chance_zrecym.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961922/-MV-_So_Soo_Bin_%EC%86%8C%EC%88%98%EB%B9%88_-_Last_Chance_necn03.mp3"),

                new Song("Love You With All My Heart", "Queen of Tears OST", "Kim Soo-hyun", "Kim Ji-won", 
                    "Crush", "Nam Hye-seung", "Kim Kyung-hee", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963612/Love_you_with_all_my_heart_cfcipd.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961950/-MV-_Crush_-_Love_You_With_All_My_Heart_%EB%AF%B8%EC%95%88%ED%95%B4_%EB%AF%B8%EC%9B%8C%ED%95%B4_%EC%82%AC%EB%9E%91%ED%95%B4_rgqolu.mp3"),

                new Song("Reasons of My Smiles", "Queen of Tears OST Part 1", "Kim Soo-hyun", "Kim Ji-won", 
                    "BSS (SEVENTEEN)", "Kwon Deok-geun", "Kang Eun-kyung", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963618/Reasons_of_my_smiles_awdah2.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961955/-MV-_BSS_%EB%B6%80%EC%84%9D%EC%88%9C_SEVENTEEN_-_The_Reasons_of_My_Smiles_%EC%9E%90%EA%BE%B8%EB%A7%8C_%EC%9B%83%EA%B2%8C_%EB%8F%BC_fai9qg.mp3"),

                new Song("Stay With Me", "Goblin OST Part 1", "Gong Yoo", "Kim Go-eun", 
                    "Chanyeol & Punch", "Rocoberry", "Lee Seung-joo", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963616/Stay_with_me_p8wjgu.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779898172/CHANYEOL_Punch_-_Stay_With_Me_Lyrics_easy_lyrics_nt8vft.m4a"),

                new Song("With You", "Our Blues OST Part 4", "Lee Byung-hun", "Shin Min-a", 
                    "Jimin & Ha Sung-woon", "Rocoberry", "Jihoon (Rocoberry)", "Korean", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963606/With_you_xlxkyl.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961937/-MV-_%EC%A7%80%EB%AF%BC_Jimin_X_%ED%95%98%EC%84%B1%EC%9A%B4_Ha_Sung-Woon_-_With_you___%EC%9A%B0%EB%A6%AC%EB%93%A4%EC%9D%98_%EB%B8%94%EB%A3%A8%EC%8A%A4_Our_Blues_OST_Part_4_r6eg0j.mp3"),

                new Song("Besabriyaan", "M.S. Dhoni: The Untold Story", "Sushant Singh Rajput", "Kiara Advani", 
                    "Armaan Malik", "Amaal Mallik", "Manoj Muntashir", "Motivational", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963992/Besabriyaan_x0rchm.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897120/Besabriyaan_-_M.S._Dhoni_-_The_Untold_Story_320_Kbps_nw0z9s.mp3"),

                new Song("Ek Zindagi", "Angrezi Medium", "Irrfan Khan", "Radhika Madan", 
                    "Tanishkaa Sanghvi, Sachin-Jigar", "Sachin-Jigar", "Jigar Saraiya", "Motivational", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964002/Ek_zindagi_kj7z4w.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897128/Ek_Zindagi_-_Angrezi_Medium_320_Kbps_eqwbih.mp3"),

                new Song("Give Me Some Sunshine", "3 Idiots", "Aamir Khan, Sharman Joshi, R. Madhavan", "Kareena Kapoor", 
                    "Suraj Jagan, Sharman Joshi", "Shantanu Moitra", "Swanand Kirkire", "Motivational", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963995/give_me_some_sunshine_sq8fpg.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897142/Give_Me_Some_Sunshine_-_Raag.Fm_ignn4a.mp3"),

                new Song("Khol De Par", "Hichki", "N/A", "Rani Mukerji", 
                    "Arijit Singh", "Jasleen Royal", "Raj Shekhar", "Motivational", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963999/khol_de_par_b3ibwd.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897160/Khol_De_Par_-_Hichki_320_Kbps_rl74cw.mp3"),

                new Song("Love You Zindagi", "Dear Zindagi", "Shah Rukh Khan", "Alia Bhatt", 
                    "Jasleen Royal, Amit Trivedi", "Amit Trivedi", "Kausar Munir", "Motivational", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964004/love_you_zindagi_graocb.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897171/Love_You_Zindagi_-_Dear_Zindagi_320_Kbps_szsqix.mp3"),

                new Song("Mera Safar", "Baazaar", "Saif Ali Khan", "Radhika Apte", 
                    "Sohail Sen", "Sohail Sen", "Jamil Ahmed", "Motivational", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769964007/Mera_safar_xfamwt.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897181/Mera_Safar_Iqlipse_Nova_320_Kbps_cpq7gl.mp3"),

                new Song("Ve Haaniyaan", "N/A", "Ravi Dubey", "Sargun Mehta", 
                    "Danny Ft. Avvy Sra", "Avvy Sra", "Sagar", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963273/Ve_haaniyan_ncwlv9.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779893292/Ve_Haaniyaan_-_Avvy_Sra_320_Kbps_1_pgb6hv.mp3"),

                new Song("Teri Aa Jatta", "N/A", "Guntaj", "Sruishty Maan", 
                    "Guntaj", "Silver Coin", "Daljit Chitti", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963275/teri_aa_jatta_ggtdxv.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779893311/Teri_Aa_Jatta_-_Guntaj_320_MyMp3Song_1_kdsaft.mp3"),

                new Song("Suniyan Suniyan", "N/A", "Juss", "N/A", 
                    "Juss", "MixSingh", "Juss", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963277/suniyan_suniyan_ob6lf7.webp", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779893316/Suniyan_Suniyan_-_Juss_320_Kbps_1_jtghnd.mp3"),

                new Song("Raataan Lambiyan", "Shershaah", "Sidharth Malhotra", "Kiara Advani", 
                    "Jubin Nautiyal, Asees Kaur", "Tanishk Bagchi", "Tanishk Bagchi", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963284/Raatan_lambiyan_sedye4.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891721/Raataan_Lambiyan_-_Shershaah_320_Kbps_dbjhzt.mp3"),

                new Song("One Love", "No Love EP", "Shubh", "N/A", 
                    "Shubh", "Shubh", "Shubh", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779893583/One_Love_n9pqhn.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891718/One_Love_-_Shubh_320_Kbps_nbbzee.mp3"),

                new Song("Ranjha", "Shershaah", "Sidharth Malhotra", "Kiara Advani", 
                    "Jasleen Royal, B Praak", "Jasleen Royal", "Anvita Dutt", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963282/ranjha_ccvbe9.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891728/Ranjha_-_Shershaah_320_Kbps_m1gh3o.mp3"),

                new Song("Softly", "Making Memories", "Karan Aujla", "Tanu Grewal", 
                    "Karan Aujla", "Ikky", "Karan Aujla", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963280/Softly_xtbvg7.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891734/Softly_-_Making_Memories_320_Kbps_xjy5gn.mp3"),

                new Song("Excuses", "Not by Chance", "A.P. Dhillon", "N/A", 
                    "A.P. Dhillon, Gurinder Gill", "Intense", "Gurinder Gill", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779893718/excuses_song_qjicp7.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891538/Excuses_320_PagalWorld.com.sb_.mp3.crdownload_bcbmyh.mp3"),

                new Song("Ikko Mikke", "Ikko Mikke", "Satinder Sartaaj", "Aditi Sharma", 
                    "Satinder Sartaaj", "Satinder Sartaaj", "Satinder Sartaaj", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779893842/ikko_mikke_nu4bt5.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891588/Ikko_-_Mikke_-_Title_Track_320_Kbps_gkvwrm.mp3"),

                new Song("Jhaanjar", "Honeymoon", "Gippy Grewal", "Jasmin Bhasin", 
                    "B Praak", "Jaani", "Jaani", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779893930/jhaanjar_dvcjxb.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891647/Jhaanjar_-_B_Praak_320_Kbps_kml1ol.mp3"),

                new Song("Maiyya Mainu", "Jersey", "Shahid Kapoor", "Mrunal Thakur", 
                    "Sachet Tandon", "Sachet-Parampara", "Shellee", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779894109/mayya_mainu_uzuzlo.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961592/Maiyya_Mainu_-_Lyrical___Jersey___Shahid_Kapoor_Mrunal_Thakur__Sachet-Parampara__Shellee___Gowtam_T_hkiyle.mp3"),

                new Song("Mann Bharrya", "Shershaah", "Sidharth Malhotra", "Kiara Advani", 
                    "B Praak", "B Praak", "Jaani", "Punjabi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779894008/mann_bhar_xersip.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779891710/Mann_Bharryaa_2.0_-_Shershaah_320_Kbps_kxvypu.mp3"),

                new Song("Salaam-E-Ishq", "Salaam-E-Ishq", "Salman Khan, John Abraham, Anil Kapoor", "Priyanka Chopra, Vidya Balan, Juhi Chawla", 
                    "Sonu Nigam, Shreya Ghoshal, Kunal Ganjawala, Sadhana Sargam", "Shankar-Ehsaan-Loy", "Sameer", "Bollywood Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963380/128Salaam-E-Ishq_-_Salaam-E-Ishq_kfymgl.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779895708/Salaam-E-Ishq_zhkhwi.mp3"),

                new Song("Aayi Nai", "Stree 2", "Rajkummar Rao", "Shraddha Kapoor", 
                    "Pawan Singh, Simran Choudhary, Divya Kumar", "Sachin-Jigar", "Amitabh Bhattacharya", "Bollywood Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963412/aayi-nai-stree-2_mx62ho.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779896452/Aayi_Nai_-_Stree_2_320_Kbps_tqevqc.mp3"),

                new Song("Cheap Thrills", "N/A", "N/A", "N/A", 
                    "Sia, Sean Paul", "Sia, Greg Kurstin", "Sia Furler, Greg Kurstin", "Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963409/cheapthrills_swvobr.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961683/Sia_-_Cheap_Thrills_Lyrics_ft._Sean_Paul_my6fq1.mp3"),

                new Song("Cruel Summer", "N/A", "N/A", "N/A", 
                    "Taylor Swift", "Taylor Swift, Jack Antonoff, St. Vincent", "Taylor Swift, Jack Antonoff, St. Vincent", "Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963366/cruel_summer_joluci.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961675/Taylor_Swift_-_Cruel_Summer_Official_Audio_pybqkr.mp3"),

                new Song("Naina", "Dangal", "Aamir Khan", "Sakshi Tanwar", 
                    "Arijit Singh", "Pritam", "Amitabh Bhattacharya", "Bollywood Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910025/musiverse/covers/pvtgungsnyvlmks0djwm.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897000/Naina_Dangal.mp3"),

                new Song("Shape of You", "N/A", "N/A", "N/A", 
                    "Ed Sheeran", "Ed Sheeran, Steve Mac, Johnny McDaid", "Ed Sheeran, Steve Mac, Johnny McDaid", "Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963407/shape_of_you_1_c45jhb.png", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779895698/Shape_of_You-_PagalSongs.Com.IN_qzxgat.mp3"),

                new Song("Sorry", "N/A", "N/A", "N/A", 
                    "Justin Bieber", "Justin Bieber, Julia Michaels, Justin Tranter, Skrillex, BloodPop", "Justin Bieber, Julia Michaels, Justin Tranter", "Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963397/sorry_justin_ymzzfx.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779895595/Sorry_320_PagalWorld.com.so_xhn2yu.mp3"),

                new Song("Stay", "N/A", "N/A", "N/A", 
                    "The Kid LAROI, Justin Bieber", "Charlton Howard, Justin Bieber, Cashmere Cat, Charlie Puth, Blake Slatkin", "Charlton Howard, Justin Bieber, Charlie Puth, Blake Slatkin", "Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963422/Stay-English-2021_rbg8bn.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961669/The_Kid_LAROI_Justin_Bieber_-_STAY_Official_Video_ca5nxm.mp3"),

                new Song("Summer High", "N/A", "N/A", "N/A", 
                    "AP Dhillon", "AP Dhillon, Gminxr", "AP Dhillon", "Punjabi Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963389/Summer-High-English_y8ngxg.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779895568/Summer_High_-_Ap_Dhillon_320_Kbps_sczapc.mp3"),

                new Song("Taki Taki", "N/A", "N/A", "N/A", 
                    "DJ Snake, Selena Gomez, Ozuna, Cardi B", "DJ Snake, Selena Gomez, Ozuna, Cardi B", "William Grigahcine, Juan Carlos Ozuna Rosado, Belcalis Almanzar, Selena Gomez", "Latin Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963425/Taki-Taki-English_pafnax.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779896445/DJ_Snake_-_Taki_Taki_ft._Selena_Gomez_Ozuna_Cardi_B_Official_Music_Video_k7fv50.m4a"),

                new Song("Tauba Tauba", "Kaal", "John Abraham, Vivek Oberoi", "Lara Dutta, Esha Deol", 
                    "Richa Sharma, Sonu Nigam", "Salim-Sulaiman", "Shabbir Ahmed", "Bollywood Pop", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963414/tauba-tauba_vdfxsm.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779897100/Tauba_Tauba_Kaal.mp3"),

                new Song("Zara Sa", "Jannat", "Emraan Hashmi", "Sonal Chauhan", 
                    "KK", "Pritam", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962528/zara_sa_lj2app.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968448/Zara_Sa_n1w1ip.mp3"),

                new Song("Jee Le Zara", "Talaash", "Aamir Khan", "Kareena Kapoor, Rani Mukerji", 
                    "Vishal Dadlani", "Ram Sampath", "Javed Akhtar", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962499/Jee_le_zara_ylcjsz.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968397/Jee_Le_Zaraa_-_Talaash_320_Kbps_h45g82.mp3"),

                new Song("Tera Mera Rishta", "Awarapan", "Emraan Hashmi", "Shriya Saran", 
                    "Mustafa Zahid", "Pritam", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962547/tera_mera_rishta_hxlqbq.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968501/Tera_Mera_Rishta_xxt5wc.mp3"),

                new Song("Tum Se Hi", "Jab We Met", "Shahid Kapoor", "Kareena Kapoor", 
                    "Mohit Chauhan", "Pritam", "Irshad Kamil", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962535/Tum_se_hi_pvrkh6.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968470/Tum_Se_Hi_n2xiht.mp3"),

                new Song("Kuch Is Tarah", "Doorie (Album)", null, null, 
                    "Atif Aslam", "Atif Aslam", "Sameer", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962505/kuch_is_tarahh_zaqodb.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968404/Kuchh_Is_Tarah_-_8_X_10_Tasveer_320_Kbps_ng4uei.mp3"),

                new Song("Lo Maan Liya", "Raaz Reboot", "Emraan Hashmi", "Kriti Kharbanda", 
                    "Arijit Singh", "Jeet Gannguli", "Kausar Munir", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910048/musiverse/covers/euicedr3hiemgf6eslhf.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968412/Lo_Maan_Liya_-_Raaz_Reboot_320_Kbps_teitnx.mp3"),

                new Song("Jannatein Kahan", "Jannat 2", "Emraan Hashmi", "Esha Gupta", 
                    "KK", "Pritam", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962490/Jannatein_kaha_buvgvd.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968390/Jannatein_Kahan_Power_Ballad_-_Jannat_2_320_Kbps_1_zwsjxw.mp3"),

                new Song("Jaavedan Hai", "Murder 3", "Randeep Hooda", "Aditi Rao Hydari, Sara Loren", 
                    "Shafqat Amanat Ali", "Pritam", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962485/Jaavedan_Hai_tz3nnn.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968383/Jaavedaan_Hai_Lyrical_Video___1920_Evil_Returns___KK_Suzanne_D_Mello_oww6d2.m4a"),

                new Song("Hasi", "Hamari Adhuri Kahani", "Emraan Hashmi", "Vidya Balan", 
                    "Ami Mishra", "Ami Mishra", "Kunaal Vermaa", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962479/Hasi_g2torn.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968375/Hasi_Male_Version_-_Hamari_Adhuri_Kahani_320_Kbps_dfegif.mp3"),

                new Song("Hai Dil Ye Mera", "Hate Story 2", "Jay Bhanushali", "Surveen Chawla", 
                    "Arijit Singh", "Mithoon", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962441/Hai_dil_ye_mera_ugcbpe.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968344/Hai_Dil_Ye_Mera_eytk5i.mp3"),

                new Song("Dil Ibaadat", "Tum Mile", "Emraan Hashmi", "Soha Ali Khan", 
                    "KK", "Pritam", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962426/dil_ibadat_h0wf0k.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968351/Dil_Ibaadat_qjcnog.mp3"),

                new Song("Deewana Kar Raha Hai", "Raaz 3", "Emraan Hashmi", "Esha Gupta", 
                    "Javed Ali", "Rashid Khan", "Sanjay Masoomm", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962409/Deewana_kar_raha_hai_brmzbm.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968337/Deewana_Kar_Raha_Hai_ng7v3b.mp3"),

                new Song("Be Intehaan", "Race 2", "Saif Ali Khan", "Deepika Padukone", 
                    "Atif Aslam, Sunidhi Chauhan", "Pritam", "Mayur Puri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910062/musiverse/covers/tfmorzuvgdcqovdnhvia.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961423/Be_Intehaan_-_Lyrical_Video___Race_2___Saif_Ali_Khan_Deepika_Padukone___Atif_Aslam___Pritam___Tips_js8z0e.mp3"),

                new Song("Aadat", "Kalyug", "Kunal Khemu", "Smiley Suri", 
                    "Atif Aslam", "Goher Mumtaz", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910067/musiverse/covers/pet15bjogbwkeil6fvvd.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968134/Aadat_1_bzwx2v.mp3"),

                new Song("Aao Milo Chalein", "Jab We Met", "Shahid Kapoor", "Kareena Kapoor", 
                    "Shaan, Ustad Sultan Khan", "Pritam", "Irshad Kamil", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910070/musiverse/covers/dvwfx4omrrzat6s2albf.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968142/Aao_Milo_Chalo_zfaqh3.mp3"),

                new Song("Beete Lamhein", "The Train", "Emraan Hashmi", "Geeta Basra", 
                    "KK", "Mithoon", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910074/musiverse/covers/cnbanfuvutcsyp8akej0.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968148/Beete_Lamhein_ssc4iu.mp3"),

                new Song("Hale Dil", "Murder 2", "Emraan Hashmi", "Jacqueline Fernandez", 
                    "Harshit Saxena", "Harshit Saxena", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910077/musiverse/covers/mei2mdsfyyzew7tiamcr.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968359/Hale_Dil_-_Murder_2_320_Kbps_xvfypk.mp3"),

                new Song("Maahi", "Raaz: The Mystery Continues", "Emraan Hashmi, Adhyayan Suman", "Kangana Ranaut", 
                    "Toshi Sabri", "Sharib-Toshi", "Sayeed Quadri", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910080/musiverse/covers/lujxjliffmtzfa1vzjlv.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968419/Maahi_-_RAAZ_-_The_Mystery_Continues_320_Kbps_ugc5p1.mp3"),

                new Song("Maula Mere Maula", "Anwar", "Siddharth Koirala", "Nauheed Cyrusi", 
                    "Roop Kumar Rathod", "Mithoon", "Mithoon", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910084/musiverse/covers/y7b8yoq9yrimowhxnfhv.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968426/Maula_Mere_Maula_-_Anwar_320_Kbps_bsudkj.mp3"),

                new Song("Pehli Nazar Mein", "Race", "Saif Ali Khan, Akshaye Khanna", "Bipasha Basu, Katrina Kaif", 
                    "Atif Aslam", "Pritam", "Sameer Anjaan", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779910087/musiverse/covers/ftowpu2lp5uzvp1rksle.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769968434/Pehli_Nazar_Mein_-_Race_320_Kbps_z4m9mn.mp3"),

                new Song("Ye Raatein Ye Mausam (Cover)", "Dilli Ka Thug (Cover)", "Kishore Kumar", "Nutan", 
                    "Sanam Band", "Ravi", "Shailendra", "Romantic", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769962541/ye_raatein_ye_mausam_bf13th.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961440/Yeh-Raaten-Yeh-Mausam-Sanam-Puri-Simran-Sehgal_knta5a.mp3"),

                new Song("Closer", "Collage (2016)", "The Chainsmokers", "Halsey", 
                    "The Chainsmokers feat. Halsey", "Andrew Taggart, Shaun Frank, Frederic Kennett, Halsey", "Andrew Taggart, Halsey, Shaun Frank, Freddy Kennett", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963177/Closer_swfvzg.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779877758/Closer-_PagalSongs.Com.IN_q9722f.mp3"),

                new Song("Godspeed", "Blonde (2016)", "Frank Ocean", null, 
                    "Frank Ocean", "Frank Ocean, Malay, Om'Mas Keith", "Frank Ocean, Malay, Om'Mas Keith", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963173/Godspeed_yn40ak.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962070/Camila_Cabello_-_GODSPEED_Official_Music_Video_alksg8.mp3"),

                new Song("Let Me Love You", "Encore (2016)", "DJ Snake", "Justin Bieber", 
                    "DJ Snake feat. Justin Bieber", "DJ Snake, Justin Bieber, Ali Tamposi, Andrew Watt, Brian Lee, Louis Bell", "Justin Bieber, Ali Tamposi, Andrew Watt, Brian Lee", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963171/let_me_love_you_g9t8kt.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779877984/Let_Me_Love_You_320_PagalWorld.com.so_hlgote.mp3"),

                new Song("Love Story", "Fearless (2008)", "Taylor Swift", null, 
                    "Taylor Swift", "Taylor Swift", "Taylor Swift", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963166/love_story_xrutms.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779878040/Love-Story_PagalNew.Com.Se_tdlrrr.mp3"),

                new Song("Lover", "Lover (2019)", "Taylor Swift", null, 
                    "Taylor Swift", "Taylor Swift", "Taylor Swift", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963163/lover_lnatuv.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962060/Taylor_Swift_-_Lover_Official_Music_Video_wzqqcl.mp3"),

                new Song("Paper Rings", "Lover (2019)", "Taylor Swift", null, 
                    "Taylor Swift", "Taylor Swift, Jack Antonoff", "Taylor Swift, Jack Antonoff", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779878566/Paper_rings_wu0u96.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769962065/Taylor_Swift_-_Paper_Rings_Official_Audio_s0ln8c.mp3"),

                new Song("Señorita", "Shawn Mendes (Deluxe) (2019)", "Shawn Mendes", "Camila Cabello", 
                    "Shawn Mendes & Camila Cabello", "Andrew Watt, Benny Blanco, Ali Tamposi, Camila Cabello, Shawn Mendes", "Ali Tamposi, Camila Cabello, Shawn Mendes, Andrew Watt, Benny Blanco", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963161/Se%C3%B1orita_tjb4yl.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779878085/Senorita-Ringtone---Shawn-Mendes-Version_PagalWorld_d5clbj.mp3"),

                new Song("You Belong with Me", "Fearless (2008)", "Taylor Swift", null, 
                    "Taylor Swift", "Taylor Swift, Liz Rose", "Taylor Swift, Liz Rose", "English", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963158/you_belong_with_me_cfnebr.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779878129/You-Belong-With-Me_320_PagalWorld_hrjpoi.mp3"),

                new Song("Dil Dhadakne Do", "Dil Dhadakne Do", "Ranveer Singh, Anil Kapoor", "Priyanka Chopra, Anushka Sharma", 
                    "Farhan Akhtar, Priyanka Chopra, Shankar Mahadevan, Yashita Sharma", "Shankar-Ehsaan-Loy", "Javed Akhtar", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963922/Dil_dhadakne_do_kz0ige.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880338/Dil_Dhadakne_Do_-_Zindagi_Na_Milegi_Dobara_320_Kbps_nmk23c.mp3"),

                new Song("Dil Diyan Gallan", "Tiger Zinda Hai", "Salman Khan", "Katrina Kaif", 
                    "Atif Aslam", "Vishal-Shekhar", "Irshad Kamil", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963916/Dil_diyan_gallan_siokkw.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880362/Dil_Diyan_Gallan_-_Tiger_Zinda_Hai_320_Kbps_byi66f.mp3"),

                new Song("Gallan Goodiyan", "Dil Dhadakne Do", "Ranveer Singh, Anil Kapoor", "Priyanka Chopra, Anushka Sharma", 
                    "Farhan Akhtar, Shankar Mahadevan, Yashita Sharma", "Shankar-Ehsaan-Loy", "Javed Akhtar", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963924/Gallan_goodiyan_aqojmf.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880334/Gallan_Goodiyaan_-_Dil_Dhadakne_Do_320_Kbps_qw4htl.mp3"),

                new Song("Kala Chashma", "Baar Baar Dekho", "Sidharth Malhotra", "Katrina Kaif", 
                    "Badshah, Neha Kakkar, Amar Arshi", "Badshah", "Amrik Singh, Kumaar", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963927/Kala_chashma_o54mp5.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880330/Kala_Chashma_lpr2gh.mp3"),

                new Song("Kar Gayi Chull", "Kapoor & Sons", "Sidharth Malhotra", "Alia Bhatt", 
                    "Badshah, Neha Kakkar", "Badshah, Amaal Mallik", "Badshah, Kumaar", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963930/Kar_gayi_chull_o4xggc.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880327/Kar_Gayi_Chull_-_Kapoor_And_Sons_Since_1921_320_Kbps_rpqw5d.mp3"),

                new Song("London Thumakda", "Queen", "Rajkummar Rao", "Kangana Ranaut", 
                    "Labh Janjua, Sonu Kakkar, Neha Kakkar", "Amit Trivedi", "Anvita Dutt", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963908/London_thumakda_fa8isi.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880321/London_Thumakda_-_Queen_320_Kbps_kwov1q.mp3"),

                new Song("Lungi Dance", "Chennai Express", "Shah Rukh Khan", "Deepika Padukone", 
                    "Yo Yo Honey Singh", "Yo Yo Honey Singh", "Yo Yo Honey Singh", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963913/Lungi_dance_o6kood.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1769961977/Lungi-Dance-Yo-Yo-Honey-Singh_x12unz.mp3"),

                new Song("O Maahi", "Raaz: Reboot", "Emraan Hashmi", "Kriti Kharbanda", 
                    "Arijit Singh", "Jeet Gannguli", "Kausar Munir", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963910/O_maahi_dqvcg5.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880315/O_Mahi_O_Mahi_320_PagalWorld.com.sb_hiz4oa.mp3"),

                new Song("Pee Loon", "Once Upon a Time in Mumbaai", "Emraan Hashmi", "Prachi Desai", 
                    "Mohit Chauhan", "Pritam", "Irshad Kamil", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963902/Pee_loon_asxh1q.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880307/Pee_Loon_Hoto_Ki_Sargam_-_Once_Upon_A_Time_In_Mumbaai_320_Kbps_jnjoak.mp3"),

                new Song("Sang Rahiyo", "N/A", "Rajkummar Rao", "Patralekha", 
                    "Jasleen Royal", "Jasleen Royal", "Neeraj Rajawat", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963905/sang_rahiyo_jwdyey.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880290/Sang-Rahiyo_Pagal-World.Com.In_pughsj.mp3"),

                new Song("The Disco Song", "Student of the Year", "Varun Dhawan, Sidharth Malhotra", "Alia Bhatt", 
                    "Benny Dayal, Sunidhi Chauhan", "Vishal-Shekhar", "Anvita Dutt", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963899/The_disco_song_faapo1.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880283/The_Disco_Song_-_Student_Of_The_Year_320_Kbps_mwzaij.mp3"),

                new Song("Ve Kamleya", "Rocky Aur Rani Kii Prem Kahani", "Ranveer Singh", "Alia Bhatt", 
                    "Arijit Singh, Shreya Ghoshal", "Pritam", "Amitabh Bhattacharya", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1769963896/Ve_kamleya_pvaghm.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880287/Ve_Kamleya_-_Rocky_Aur_Rani_Kii_Prem_Kahaani_320_Kbps_volfss.mp3"),

                new Song("Zaalima", "Raees", "Shah Rukh Khan", "Mahira Khan", 
                    "Arijit Singh, Harshdeep Kaur", "JAM8", "Amitabh Bhattacharya", "Hindi", 
                    "https://res.cloudinary.com/dzh4n8fxx/image/upload/v1779880056/zaalima_loxxvc.jpg", 
                    "https://res.cloudinary.com/dzh4n8fxx/video/upload/v1779880311/O-Zaalima-o-Zaalima_PagalWorlld.Com_a7gt3w.mp3")
            );

            List<Song> existingSongs = songService.getAllSongs();
            int seededCount = 0;
            int updatedCount = 0;
            for (Song song : songs) {
                Optional<Song> existingOpt = existingSongs.stream()
                    .filter(s -> s.getSongName().equalsIgnoreCase(song.getSongName().trim()))
                    .findFirst();
                if (existingOpt.isPresent()) {
                    Song existing = existingOpt.get();
                    boolean changed = false;
                    if (song.getImageUrl() != null && !song.getImageUrl().equals(existing.getImageUrl())) {
                        existing.setImageUrl(song.getImageUrl());
                        changed = true;
                    }
                    if (song.getSongUrl() != null && !song.getSongUrl().equals(existing.getSongUrl())) {
                        existing.setSongUrl(song.getSongUrl());
                        changed = true;
                    }
                    if (changed) {
                        songService.updateSong(existing.getId(), existing);
                        updatedCount++;
                    }
                } else {
                    songService.saveSong(song);
                    seededCount++;
                }
            }
            List<Song> finalSongsList = songService.getAllSongs();
            return ResponseEntity.ok(Map.of(
                "message", "Database seeding and cleanup completed successfully!",
                "duplicates_deleted", finalDuplicatesDeleted,
                "songs_added", seededCount,
                "songs_updated", updatedCount,
                "total_songs_in_db", finalSongsList.size(),
                "existing_song_names", finalSongsList.stream().map(Song::getSongName).toList()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================
    // CREATE SONG
    // =========================
    @PostMapping
    public ResponseEntity<?> addSong(
            @RequestParam("songName") String songName,
            @RequestParam("movie") String movie,
            @RequestParam("singer") String singer,
            @RequestParam(value = "actor", required = false) String actor,
            @RequestParam(value = "actress", required = false) String actress,
            @RequestParam("composer") String composer,
            @RequestParam("lyricist") String lyricist,
            @RequestParam("category") String category,
            @RequestParam("songFile") MultipartFile songFile,
            @RequestParam("imageFile") MultipartFile imageFile) {
        try {
            String songUrl = cloudinaryService.uploadFile(songFile, "auto");
            String imageUrl = cloudinaryService.uploadFile(imageFile, "auto");

            Song song = new Song(songName, movie, actor, actress, singer, composer, lyricist, category, imageUrl, songUrl);
            Song saved = songService.saveSong(song);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    private Optional<User> getOptionalAuthenticatedUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return Optional.empty();
        }
        String email = (String) authentication.getPrincipal();
        return userRepository.findByEmail(email);
    }

    // =========================
    // GET ALL SONGS
    // =========================
    @GetMapping
    public ResponseEntity<List<Song>> getAllSongs() {
        List<Song> allSongs = new java.util.ArrayList<>(songService.getAllSongs());
        Optional<User> userOpt = getOptionalAuthenticatedUser();
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            allSongs.removeIf(song -> user.getHiddenSongs().contains(song));
        }
        return ResponseEntity.ok(allSongs);
    }

    // =========================
    // GET SONGS BY CATEGORY
    // =========================
    @GetMapping("/category/{category}")
    public ResponseEntity<List<Song>> getByCategory(@PathVariable String category) {
        List<Song> songs = new java.util.ArrayList<>(songService.getSongsByCategory(category));
        Optional<User> userOpt = getOptionalAuthenticatedUser();
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            songs.removeIf(song -> user.getHiddenSongs().contains(song));
        }
        return ResponseEntity.ok(songs);
    }

    // =========================
    // SEARCH SONGS
    // =========================
    @GetMapping("/search")
    public ResponseEntity<List<Song>> searchSongs(@RequestParam String q) {
        List<Song> songs = new java.util.ArrayList<>(songService.searchSongs(q));
        Optional<User> userOpt = getOptionalAuthenticatedUser();
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            songs.removeIf(song -> user.getHiddenSongs().contains(song));
        }
        return ResponseEntity.ok(songs);
    }

    // =========================
    // UPDATE SONG
    // =========================
    @PutMapping("/{id}")
    public ResponseEntity<?> updateSong(
            @PathVariable Long id,
            @RequestParam("songName") String songName,
            @RequestParam("movie") String movie,
            @RequestParam("singer") String singer,
            @RequestParam(value = "actor", required = false) String actor,
            @RequestParam(value = "actress", required = false) String actress,
            @RequestParam("composer") String composer,
            @RequestParam("lyricist") String lyricist,
            @RequestParam("category") String category,
            @RequestParam(value = "songFile", required = false) MultipartFile songFile,
            @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) {
        try {
            Song existingSong = songService.getSongById(id);

            String songUrl = existingSong.getSongUrl();
            if (songFile != null && !songFile.isEmpty()) {
                songUrl = cloudinaryService.uploadFile(songFile, "auto");
            }

            String imageUrl = existingSong.getImageUrl();
            if (imageFile != null && !imageFile.isEmpty()) {
                imageUrl = cloudinaryService.uploadFile(imageFile, "auto");
            }

            existingSong.setSongName(songName);
            existingSong.setMovie(movie);
            existingSong.setArtist(singer);
            existingSong.setActor(actor);
            existingSong.setActress(actress);
            existingSong.setComposer(composer);
            existingSong.setLyricist(lyricist);
            existingSong.setCategory(category);
            existingSong.setSongUrl(songUrl);
            existingSong.setImageUrl(imageUrl);

            Song updated = songService.updateSong(id, existingSong);
            return ResponseEntity.ok(updated);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        }
    }

    // =========================
    // DELETE (HIDE) SONG FOR CURRENT USER
    // =========================
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSong(@PathVariable Long id) {
        try {
            User user = getAuthenticatedUser();
            Song song = songService.getSongById(id);

            user.getHiddenSongs().add(song);
            userRepository.save(user);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================
    // GET HIDDEN SONGS FOR CURRENT USER
    // =========================
    @GetMapping("/hidden")
    public ResponseEntity<?> getHiddenSongs() {
        try {
            User user = getAuthenticatedUser();
            return ResponseEntity.ok(user.getHiddenSongs());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================
    // UNHIDE SONG FOR CURRENT USER
    // =========================
    @PostMapping("/{id}/unhide")
    public ResponseEntity<?> unhideSong(@PathVariable Long id) {
        try {
            User user = getAuthenticatedUser();
            Song song = songService.getSongById(id);

            user.getHiddenSongs().remove(song);
            userRepository.save(user);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    private User getAuthenticatedUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            throw new RuntimeException("Unauthorized");
        }
        String email = (String) authentication.getPrincipal();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    // =========================
    // LIKE SONG
    // =========================
    @PostMapping("/{songId}/like")
    public ResponseEntity<?> likeSong(@PathVariable Long songId) {
        try {
            User user = getAuthenticatedUser();
            Song song = songService.getSongById(songId);

            if (user.getLikedSongs().add(song)) {
                userRepository.save(user);
            }
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================
    // UNLIKE SONG
    // =========================
    @PostMapping("/{songId}/unlike")
    public ResponseEntity<?> unlikeSong(@PathVariable Long songId) {
        try {
            User user = getAuthenticatedUser();
            Song song = songService.getSongById(songId);

            if (user.getLikedSongs().remove(song)) {
                userRepository.save(user);
            }
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================
    // GET LIKED SONGS
    // =========================
    @GetMapping("/liked")
    public ResponseEntity<?> getLikedSongs() {
        try {
            User user = getAuthenticatedUser();
            return ResponseEntity.ok(user.getLikedSongs());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
