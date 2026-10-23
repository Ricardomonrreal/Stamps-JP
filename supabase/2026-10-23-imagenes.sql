-- Migración 2026-10-23: imágenes, línea, nombre en japonés y catálogo JR West de Osaka.
-- Ejecutar UNA vez en Supabase > SQL Editor (después de schema.sql).

alter table public.stamps
  add column if not exists name_ja text check (length(name_ja) <= 120),
  add column if not exists line text check (length(line) <= 120),
  add column if not exists photo_url text check (photo_url ~ '^https://'),
  add column if not exists stamp_url text check (stamp_url ~ '^https://');

-- Bucket público para fotos del lugar y de la estampa (máx. 5 MB, solo imágenes)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('stamp-images', 'stamp-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Cada usuario con sesión sube solo dentro de su carpeta <uid>/...
create policy "upload own folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'stamp-images' and (storage.foldername(name))[1] = auth.uid()::text);

-- Estampa de Shinsaibashi (Osaka Metro). Imagen CC0 de Wikimedia Commons (autor: Taufik).
insert into public.stamps (name, name_ja, line, lat, lng, description, stamp_url, photo_url, status, created_by)
select 'Shinsaibashi (Osaka Metro)', '心斎橋駅', 'Midosuji Line', 34.67502, 135.50031,
  'Estampa de Osaka Metro en la estación.',
  'https://commons.wikimedia.org/wiki/Special:FilePath/Eki_stamp_Shinsaibashi_Station_20250829_145345.jpg?width=480',
  'https://commons.wikimedia.org/wiki/Special:FilePath/%E5%A4%A7%E9%98%AA%E3%83%A1%E3%83%88%E3%83%AD%E5%BF%83%E6%96%8E%E6%A9%8B%E9%A7%85%E5%BE%A1%E5%A0%82%E7%AD%8B%E7%B7%9A%E3%83%9B%E3%83%BC%E3%83%A02.jpg?width=640',
  'approved', null
where not exists (select 1 from public.stamps where name = 'Shinsaibashi (Osaka Metro)');

update public.stamps set name_ja = '大阪城', photo_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Osaka_Castle_02bs3200.jpg?width=640' where name = 'Castillo de Osaka';
update public.stamps set name_ja = '通天閣' where name = 'Tsutenkaku';
update public.stamps set name_ja = 'なんば駅', line = 'Nankai Main Line' where name = 'Nankai Namba';

-- Estaciones JR West en Osaka con estampa oficial según https://www.jr-odekake.net/navi/stamp_eki/
-- Coordenadas y fotos: Wikipedia / Wikimedia Commons (licencias libres, ver cada archivo).
-- Las imágenes de las estampas JR no tienen licencia libre: las suben los usuarios.
update public.stamps set name_ja = '天王寺駅', line = 'Osaka Loop Line', photo_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Tennoji_Station_20221209140008.jpg?width=640' where name = 'JR Tennoji';
update public.stamps set name_ja = '新大阪駅', line = 'Sanyo Shinkansen', photo_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Shin-%C5%8Csaka_Station.jpg?width=640' where name = 'JR Shin-Osaka';
update public.stamps set name_ja = '大阪駅', line = 'JR Kyoto Line', photo_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Osaka_Station_2026.jpg?width=640' where name = 'JR Osaka';

insert into public.stamps (name, name_ja, line, city, lat, lng, photo_url) 
select v.*, 'Estampa oficial JR West (lista JR Odekake). Suele estar junto al torniquete o la ventanilla; pregunta al personal.', 'approved', null
from (values
  ('JR Kashima', '加島駅', 'JR Tozai Line', 'Osaka', 34.7275, 135.45418, 'https://commons.wikimedia.org/wiki/Special:FilePath/Osaka-Kashima-station.jpg?width=640'),
  ('JR Kitashinchi', '北新地駅', 'JR Tozai Line', 'Osaka', 34.69832, 135.49704, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kitashinchi_station_central_entrance.jpg?width=640'),
  ('JR Osakajo-kitazume', '大阪城北詰駅', 'JR Tozai Line', 'Osaka', 34.69403, 135.52618, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_West_%C5%8Csakaj%C5%8Dkitazume_Station_Exit_3.jpg?width=640'),
  ('JR Osakatemmangu', '大阪天満宮駅', 'JR Tozai Line', 'Osaka', 34.69741, 135.51344, 'https://commons.wikimedia.org/wiki/Special:FilePath/%C5%8Csaka-temmang%C5%AB_Station_Entrance_and_Exit_7.jpg?width=640'),
  ('JR Mitejima', '御幣島駅', 'JR Tozai Line', 'Osaka', 34.71259, 135.45568, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_West_Mitejima_Station_Exit_1.jpg?width=640'),
  ('JR Shin-Fukushima', '新福島駅', 'JR Tozai Line', 'Osaka', 34.69496, 135.48567, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_West_Shin-Fukushima_Station_Exit_1.jpg?width=640'),
  ('JR Ebie', '海老江駅', 'JR Tozai Line', 'Osaka', 34.69544, 135.47328, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR%E8%A5%BF%E6%97%A5%E6%9C%AC%E6%B5%B7%E8%80%81%E6%B1%9F%E9%A7%852%E5%8F%B7%E5%87%BA%E5%8F%A3.jpg?width=640'),
  ('JR Shuntokumichi', 'JR俊徳道駅', 'Osaka Higashi Line', 'Higashiosaka', 34.65845, 135.57248, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR-Shuntokumichi_Station_2019%2C08.jpg?width=640'),
  ('JR Kawachi-Eiwa', 'JR河内永和駅', 'Osaka Higashi Line', 'Higashiosaka', 34.66416, 135.57235, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR-Kawachi-Eiwa_Station_2019%2C08.jpg?width=640'),
  ('JR Awaji', 'JR淡路駅', 'Osaka Higashi Line', 'Osaka', 34.74069, 135.51986, 'https://commons.wikimedia.org/wiki/Special:FilePath/Jei%C4%81ru_awajieki_nishiguchi_1.png?width=640'),
  ('JR Noe', 'JR野江駅', 'Osaka Higashi Line', 'Osaka', 34.70694, 135.54139, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR-Noe_Station_in_201903_003.jpg?width=640'),
  ('JR Nagase', 'JR長瀬駅', 'Osaka Higashi Line', 'Higashiosaka', 34.65004, 135.57032, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Nagase_Station.jpg?width=640'),
  ('JR Minami-Suita', '南吹田駅', 'Osaka Higashi Line', 'Suita', 34.74944, 135.51125, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Minami-Suita_Station.jpg?width=640'),
  ('JR Shirokitakoendori', '城北公園通駅', 'Osaka Higashi Line', 'Osaka', 34.72347, 135.53069, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shirokitakoendori_Station_west_20190317.jpg?width=640'),
  ('JR Shin-Kami', '新加美駅', 'Osaka Higashi Line', 'Osaka', 34.62704, 135.56831, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shin-Kami_station_202001.jpg?width=640'),
  ('JR Kizuri-Kamikita', '衣摺加美北駅', 'Osaka Higashi Line', 'Higashiosaka', 34.63833, 135.56703, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Kizuri-Kamikita_Station_20230314.jpg?width=640'),
  ('JR Takaida-Chuo', '高井田中央駅', 'Osaka Higashi Line', 'Higashiosaka', 34.67911, 135.57246, 'https://commons.wikimedia.org/wiki/Special:FilePath/Takaida-ChuoSt200803.JPG?width=640'),
  ('JR Kyobashi', '京橋駅', 'Osaka Loop Line', 'Osaka', 34.696, 135.5347, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Kyobashi_Station.jpg?width=640'),
  ('JR Imamiya', '今宮駅', 'Osaka Loop Line', 'Osaka', 34.65418, 135.49304, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Imamiya_Station.jpg?width=640'),
  ('JR Taisho', '大正駅', 'Osaka Loop Line', 'Osaka', 34.66552, 135.47997, 'https://commons.wikimedia.org/wiki/Special:FilePath/JRWest_Taishou_Station.jpg?width=640'),
  ('JR Osakajokoen', '大阪城公園駅', 'Osaka Loop Line', 'Osaka', 34.68858, 135.53448, 'https://commons.wikimedia.org/wiki/Special:FilePath/Osakajokoen_Sta01s4s3200.jpg?width=640'),
  ('JR Temma', '天満駅', 'Osaka Loop Line', 'Osaka', 34.70493, 135.51214, 'https://commons.wikimedia.org/wiki/Special:FilePath/Temma-Station-2024.jpg?width=640'),
  ('JR Teradacho', '寺田町駅', 'Osaka Loop Line', 'Osaka', 34.64788, 135.52337, 'https://commons.wikimedia.org/wiki/Special:FilePath/Teradacho-Station01.jpg?width=640'),
  ('JR Bentencho', '弁天町駅', 'Osaka Loop Line', 'Osaka', 34.6697, 135.46223, 'https://commons.wikimedia.org/wiki/Special:FilePath/Bentencho_Station.jpg?width=640'),
  ('JR Shin-Imamiya', '新今宮駅', 'Osaka Loop Line', 'Osaka', 34.65017, 135.50069, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shin-Imamiya_Station_%28external_appearance%29.JPG?width=640'),
  ('JR Momodani', '桃谷駅', 'Osaka Loop Line', 'Osaka', 34.65855, 135.52789, 'https://commons.wikimedia.org/wiki/Special:FilePath/Momodani_Station_west_exit_202001.jpg?width=640'),
  ('JR Sakuranomiya', '桜ノ宮駅', 'Osaka Loop Line', 'Osaka', 34.70492, 135.52033, 'https://commons.wikimedia.org/wiki/Special:FilePath/Sakuranomiya_Station_west_entrance_2020.jpg?width=640'),
  ('JR Morinomiya', '森ノ宮駅', 'Osaka Loop Line', 'Osaka', 34.6811, 135.53384, 'https://commons.wikimedia.org/wiki/Special:FilePath/Morinomiya_Station_2026.jpg?width=640'),
  ('JR Tamatsukuri', '玉造駅', 'Osaka Loop Line', 'Osaka', 34.67462, 135.53022, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Tamatsukuri_Station_north_entrance_2019.jpg?width=640'),
  ('JR Fukushima', '福島駅', 'Osaka Loop Line', 'Osaka', 34.69714, 135.48658, 'https://commons.wikimedia.org/wiki/Special:FilePath/Fukushima_Station_%28JR_West%29_202605.jpg?width=640'),
  ('JR Ashiharabashi', '芦原橋駅', 'Osaka Loop Line', 'Osaka', 34.65903, 135.48892, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Ashiharabashi_Station_North_Gate.jpg?width=640'),
  ('JR Nishikujo', '西九条駅', 'Osaka Loop Line', 'Osaka', 34.68266, 135.46679, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Hanshin_Nishikuj%C5%8D_Station_2020.jpg?width=640'),
  ('JR Noda', '野田駅', 'Osaka Loop Line', 'Osaka', 34.68898, 135.47486, 'https://commons.wikimedia.org/wiki/Special:FilePath/JRW_Noda_Station_entrance_2020.jpg?width=640'),
  ('JR Tsuruhashi', '鶴橋駅', 'Osaka Loop Line', 'Osaka', 34.66535, 135.5313, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR%E9%B6%B4%E6%A9%8B%E9%A7%85%E3%83%BB%E8%BF%91%E9%89%84%E6%94%B9%E6%9C%AD%E5%8F%A3_2022.jpg?width=640'),
  ('JR Sojiji', 'JR総持寺駅', 'JR Kyoto Line', 'Ibaraki', 34.82861, 135.57778, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_West_JR-S%C5%8Djiji_Station_South_Exit.jpg?width=640'),
  ('JR Senrioka', '千里丘駅', 'JR Kyoto Line', 'Settsu', 34.79129, 135.55134, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Senrioka_Station_-_panoramio_%2813%29.jpg?width=640'),
  ('JR Suita', '吹田駅', 'JR Kyoto Line', 'Suita', 34.76317, 135.52367, 'https://commons.wikimedia.org/wiki/Special:FilePath/Suita_Station.JPG?width=640'),
  ('JR Tsukamoto', '塚本駅', 'JR Kyoto Line', 'Osaka', 34.71258, 135.46888, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Tsukamoto_Station.jpg?width=640'),
  ('JR Kishibe', '岸辺駅', 'JR Kyoto Line', 'Suita', 34.77681, 135.54162, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kishibe_Station_%2802%29_IMG_4641r_R_20150808.JPG?width=640'),
  ('JR Shimamoto', '島本駅', 'JR Kyoto Line', 'Shimamoto', 34.88065, 135.66278, 'https://commons.wikimedia.org/wiki/Special:FilePath/JRW-ShimamotoStation-EastGate.jpg?width=640'),
  ('JR Settsu-Tonda', '摂津富田駅', 'JR Kyoto Line', 'Takatsuki', 34.83767, 135.59335, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_West_Settsu-Tonda_Station_North_Exit.jpg?width=640'),
  ('JR Higashi-Yodogawa', '東淀川駅', 'JR Kyoto Line', 'Osaka', 34.73951, 135.50419, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Higashi-Yodogawa_Station_East_Gate.jpg?width=640'),
  ('JR Ibaraki', '茨木駅', 'JR Kyoto Line', 'Ibaraki', 34.81535, 135.56224, 'https://commons.wikimedia.org/wiki/Special:FilePath/Ibaraki_Station_Ibaraki_Osaka_pref_Japan01-r.jpg?width=640'),
  ('JR Takatsuki', '高槻駅', 'JR Kyoto Line', 'Takatsuki', 34.85171, 135.61768, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Takatsuki_Station_20190907.jpg?width=640'),
  ('JR Ajikawaguchi', '安治川口駅', 'JR Yumesaki Line', 'Osaka', 34.67382, 135.4441, 'https://commons.wikimedia.org/wiki/Special:FilePath/Ajigawaguchi_Station_%2801%29_IMG_6711_20130811.JPG?width=640'),
  ('JR Sakurajima', '桜島駅', 'JR Yumesaki Line', 'Osaka', 34.66194, 135.43217, 'https://commons.wikimedia.org/wiki/Special:FilePath/Sakurajima_Station_20190201-2.jpg?width=640'),
  ('JR Suminodo', '住道駅', 'Gakkentoshi Line', 'Daito', 34.70625, 135.62118, 'https://commons.wikimedia.org/wiki/Special:FilePath/Suminodo_Station_201803.jpg?width=640'),
  ('JR Shijonawate', '四条畷駅', 'Gakkentoshi Line', 'Daito', 34.73044, 135.63934, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Shijonawate_Station_North_Side.jpg?width=640'),
  ('JR Tokuan', '徳庵駅', 'Gakkentoshi Line', 'Higashiosaka', 34.69244, 135.58134, 'https://commons.wikimedia.org/wiki/Special:FilePath/Tokuan_Station_west_entrance.jpg?width=640'),
  ('JR Shinobugaoka', '忍ケ丘駅', 'Gakkentoshi Line', 'Shijonawate', 34.74591, 135.64555, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shinobugaoka_station_building.jpg?width=640'),
  ('JR Hanaten', '放出駅', 'Gakkentoshi Line', 'Osaka', 34.68804, 135.563, 'https://commons.wikimedia.org/wiki/Special:FilePath/Hanaten-South.jpg?width=640'),
  ('JR Hoshida', '星田駅', 'Gakkentoshi Line', 'Katano', 34.76731, 135.66361, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Hoshida_Station_20200607.jpg?width=640'),
  ('JR Kawachi-Iwafune', '河内磐船駅', 'Gakkentoshi Line', 'Katano', 34.77633, 135.68452, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Kawachi-Iwafune_Station.jpg?width=640'),
  ('JR Tsuda', '津田駅', 'Gakkentoshi Line', 'Hirakata', 34.80117, 135.69761, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Tsuda_Station.jpg?width=640'),
  ('JR Nozaki', '野崎駅', 'Gakkentoshi Line', 'Daito', 34.71869, 135.63714, 'https://commons.wikimedia.org/wiki/Special:FilePath/Nozaki_Station_%28Osaka%29_west_entrance.jpg?width=640'),
  ('JR Nagao', '長尾駅', 'Gakkentoshi Line', 'Hirakata', 34.82599, 135.71276, 'https://commons.wikimedia.org/wiki/Special:FilePath/Nagaostation2.jpg?width=640'),
  ('JR Shigino', '鴫野駅', 'Gakkentoshi Line', 'Osaka', 34.69266, 135.54522, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Shigino_Station_20190320.jpg?width=640'),
  ('JR Konoikeshinden', '鴻池新田駅', 'Gakkentoshi Line', 'Higashiosaka', 34.69882, 135.59778, 'https://commons.wikimedia.org/wiki/Special:FilePath/Konoikeshinden_Station_%2804%29_IMG_1887_R_20150321.JPG?width=640'),
  ('JR Namba', 'JR難波駅', 'Yamatoji Line', 'Osaka', 34.66642, 135.49533, 'https://commons.wikimedia.org/wiki/Special:FilePath/Osaka_City_Air_Terminal_building_202605.jpg?width=640'),
  ('JR Kyuhoji', '久宝寺駅', 'Yamatoji Line', 'Yao', 34.62235, 135.58433, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kyuhoji_Station.jpg?width=640'),
  ('JR Yao', '八尾駅', 'Yamatoji Line', 'Yao', 34.61709, 135.59697, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Yao_Station_20140730.jpg?width=640'),
  ('JR Kami', '加美駅', 'Yamatoji Line', 'Osaka', 34.62682, 135.56724, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kami_Station_south_entrance_202509.jpg?width=640'),
  ('JR Hirano', '平野駅', 'Yamatoji Line', 'Osaka', 34.63083, 135.55167, 'https://commons.wikimedia.org/wiki/Special:FilePath/JRW_Hirano_Station_south_entrance_202509.jpg?width=640'),
  ('JR Shiki', '志紀駅', 'Yamatoji Line', 'Yao', 34.60057, 135.6156, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shiki_Station_%28Osaka%29%2C_ekisha.jpg?width=640'),
  ('JR Tobu-shijo-mae', '東部市場前駅', 'Yamatoji Line', 'Osaka', 34.63815, 135.53769, 'https://commons.wikimedia.org/wiki/Special:FilePath/T%C5%8Dbushij%C5%8Dmae_Station_west_entrance_202509.jpg?width=640'),
  ('JR Kashiwara', '柏原駅', 'Yamatoji Line', 'Kashiwara', 34.58676, 135.62326, 'https://commons.wikimedia.org/wiki/Special:FilePath/JRW_Kintetsu_Kashiwara-STA_West.jpg?width=640'),
  ('JR Kawachi-Katakami', '河内堅上駅', 'Yamatoji Line', 'Kashiwara', 34.574, 135.66289, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kawachi-Katakami_Station_202509.jpg?width=640'),
  ('JR Kansai Airport', '関西空港駅', 'Kansai Airport Line', 'Izumisano', 34.43591, 135.24349, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kansai_Airport_Station02s3.jpg?width=640'),
  ('JR Mikunigaoka', '三国ケ丘駅', 'Hanwa Line', 'Sakai', 34.56526, 135.49279, 'https://commons.wikimedia.org/wiki/Special:FilePath/JRW-NANKAI_Mikunigaoka_station_201908.jpg?width=640'),
  ('JR Uenoshiba', '上野芝駅', 'Hanwa Line', 'Sakai', 34.54985, 135.47854, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Uenoshiba_Station.jpg?width=640'),
  ('JR Shimomatsu', '下松駅', 'Hanwa Line', 'Kishiwada', 34.45746, 135.39687, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Shimomatsu_Station.jpg?width=640'),
  ('JR Kumeda', '久米田駅', 'Hanwa Line', 'Kishiwada', 34.4655, 135.4055, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kumeda_Station_east_entrance.jpg?width=640'),
  ('JR Shinodayama', '信太山駅', 'Hanwa Line', 'Izumi', 34.49971, 135.43272, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shinodayama_Station_east_entrance.jpg?width=640'),
  ('JR Kita-Shinoda', '北信太駅', 'Hanwa Line', 'Izumi', 34.50997, 135.44115, 'https://commons.wikimedia.org/wiki/Special:FilePath/Kita-Shinoda_Station_east_entrance.jpg?width=640'),
  ('JR Minami-Tanabe', '南田辺駅', 'Hanwa Line', 'Osaka', 34.62567, 135.52064, 'https://commons.wikimedia.org/wiki/Special:FilePath/Minami-Tanabe_Station_2018.jpg?width=640'),
  ('JR Izumi-Fuchu', '和泉府中駅', 'Hanwa Line', 'Izumi', 34.48849, 135.42451, 'https://commons.wikimedia.org/wiki/Special:FilePath/%E5%92%8C%E6%B3%89%E5%BA%9C%E4%B8%AD%E9%A7%85.JPG?width=640'),
  ('JR Izumi-Hashimoto', '和泉橋本駅', 'Hanwa Line', 'Kaizuka', 34.4275, 135.35892, 'https://commons.wikimedia.org/wiki/Special:FilePath/Izumi-Hashimoto_stn.jpg?width=640'),
  ('JR Izumi-Sunagawa', '和泉砂川駅', 'Hanwa Line', 'Sennan', 34.36077, 135.28169, 'https://commons.wikimedia.org/wiki/Special:FilePath/%E5%92%8C%E6%B3%89%E7%A0%82%E5%B7%9D%E9%A7%85_%E8%A5%BF%E5%8F%A3_2022.jpg?width=640'),
  ('JR Izumi-Tottori', '和泉鳥取駅', 'Hanwa Line', 'Hannan', 34.34208, 135.26294, 'https://commons.wikimedia.org/wiki/Special:FilePath/Izumi-Tottori_Station_West_exit_20260329.jpg?width=640'),
  ('JR Sakaishi', '堺市駅', 'Hanwa Line', 'Sakai', 34.57719, 135.49833, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Sakaishi_Station_0.jpg?width=640'),
  ('JR Tonoki', '富木駅', 'Hanwa Line', 'Takaishi', 34.52286, 135.45163, 'https://commons.wikimedia.org/wiki/Special:FilePath/Tonoki_Station_east_entrance.jpg?width=640'),
  ('JR Abikocho', '我孫子町駅', 'Hanwa Line', 'Osaka', 34.6021, 135.50664, 'https://commons.wikimedia.org/wiki/Special:FilePath/Abikocho_stn.jpg?width=640'),
  ('JR Shinge', '新家駅', 'Hanwa Line', 'Sennan', 34.372, 135.29859, 'https://commons.wikimedia.org/wiki/Special:FilePath/Shinge_Station_202606.jpg?width=640'),
  ('JR Hineno', '日根野駅', 'Hanwa Line', 'Izumisano', 34.39013, 135.331, 'https://commons.wikimedia.org/wiki/Special:FilePath/Hineno_Station_east_entrance.jpg?width=640'),
  ('JR Sugimotocho', '杉本町駅', 'Hanwa Line', 'Osaka', 34.59385, 135.50293, 'https://commons.wikimedia.org/wiki/Special:FilePath/Sugimotocho_station_West_entrance_20160928.jpg?width=640'),
  ('JR Higashi-Kishiwada', '東岸和田駅', 'Hanwa Line', 'Kishiwada', 34.44872, 135.38515, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Higashi-Kishiwada_Station.jpg?width=640'),
  ('JR Higashi-Hagoromo', '東羽衣駅', 'Hanwa Line', 'Takaishi', 34.5352, 135.44268, 'https://commons.wikimedia.org/wiki/Special:FilePath/Higashi-Hagoromo_Station_20190806.jpg?width=640'),
  ('JR Higashi-Kaizuka', '東貝塚駅', 'Hanwa Line', 'Kaizuka', 34.43953, 135.37244, 'https://commons.wikimedia.org/wiki/Special:FilePath/Higashi-Kaizuka_Station_east_entrance.jpg?width=640'),
  ('JR Tsukuno', '津久野駅', 'Hanwa Line', 'Sakai', 34.54224, 135.46833, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR%E9%98%AA%E5%92%8C%E7%B7%9A_%E6%B4%A5%E4%B9%85%E9%87%8E%E9%A7%85_Tsukuno_station_2012.12.14_-_panoramio.jpg?width=640'),
  ('JR Asaka', '浅香駅', 'Hanwa Line', 'Sakai', 34.58482, 135.50244, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Asaka_Station.jpg?width=640'),
  ('JR Kumatori', '熊取駅', 'Hanwa Line', 'Kumatori', 34.40658, 135.34134, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Kumatori_Station.jpg?width=640'),
  ('JR Mozu', '百舌鳥駅', 'Hanwa Line', 'Sakai', 34.55806, 135.48861, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Mozu_Station.jpg?width=640'),
  ('JR Bishoen', '美章園駅', 'Hanwa Line', 'Osaka', 34.63807, 135.52396, 'https://commons.wikimedia.org/wiki/Special:FilePath/Bishoen-sta_2021Feb5th.jpg?width=640'),
  ('JR Nagai', '長居駅', 'Hanwa Line', 'Osaka', 34.61111, 135.5126, 'https://commons.wikimedia.org/wiki/Special:FilePath/Hanwa_line_Nagai_station_1.jpg?width=640'),
  ('JR Otori', '鳳駅', 'Hanwa Line', 'Sakai', 34.53213, 135.45886, 'https://commons.wikimedia.org/wiki/Special:FilePath/JR_Otori_Station_2025.jpg?width=640'),
  ('JR Tsurugaoka', '鶴ケ丘駅', 'Hanwa Line', 'Osaka', 34.61772, 135.51661, 'https://commons.wikimedia.org/wiki/Special:FilePath/%E9%B6%B4%E3%83%B6%E4%B8%98%E9%A7%85.jpg?width=640')
) as v(name, name_ja, line, city, lat, lng, photo_url)
where not exists (select 1 from public.stamps s where s.name = v.name);
