-- MySQL dump 10.13  Distrib 9.7.1, for macos15.7 (arm64)
--
-- Host: localhost    Database: inventory_management
-- ------------------------------------------------------
-- Server version	9.7.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'b3bad0ec-7a11-11f1-b288-bc4b4061279e:1-94';

--
-- Table structure for table `b2b_order_items`
--

DROP TABLE IF EXISTS `b2b_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `b2b_order_items` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` float NOT NULL,
  `unit_price` float NOT NULL,
  `subtotal` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `b2b_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `b2b_orders` (`id`),
  CONSTRAINT `b2b_order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `b2b_order_items`
--

LOCK TABLES `b2b_order_items` WRITE;
/*!40000 ALTER TABLE `b2b_order_items` DISABLE KEYS */;
INSERT INTO `b2b_order_items` VALUES ('09726755-7d5b-4a88-81f8-3978928ee727','6ed6a977-0815-4fd1-baef-14531153dc83','581fc738-b060-4a3c-8bf1-b454f483701f',2,7200,14400),('0df2eb1a-60df-4387-a195-33abe18eeb93','ebeae97f-dcbb-4a4b-9510-ef04645c7577','83a27600-c41c-44ba-88f1-bfd9fe3c4678',10,1400,14000),('4db49827-9f0f-462d-b236-1c7fca3eb05c','900db1ac-76df-4196-9784-65cfadb19f6c','bcd6f86e-16e5-44cd-ae18-45903e84bdb4',30,950,28500),('66397fe4-aac5-4c56-a41a-41069b792492','900db1ac-76df-4196-9784-65cfadb19f6c','18c352bc-bd18-40e2-a581-daa23e539b98',60,280,16800),('898b17a8-dfb7-4f85-adca-09bf015e12fc','6ed6a977-0815-4fd1-baef-14531153dc83','87eca360-ffe3-4287-8ff1-8047e6e9a09a',15,1800,27000),('a9f4c07a-84f6-486f-8a6d-f8401dac559d','136e3c1a-60db-4f71-b860-faa3b26774f7','7d23e1c2-e0cd-4936-9746-8c4696c9e786',50,220,11000),('df7018e2-53ab-4ccd-85b5-754ef866c177','f362440e-f85e-41af-a453-1ae7d513d333','c2ca6671-65f6-4477-ae4c-20a9040f5c5e',5,24,120),('f00aba0f-f6af-4766-83b5-57a3e92e2b92','136e3c1a-60db-4f71-b860-faa3b26774f7','b737492a-0f27-4ec5-998a-a4453163dbb4',5,5500,27500),('f83e9a27-1b8e-4f3c-8805-6573af339b01','f362440e-f85e-41af-a453-1ae7d513d333','169a8be5-3f15-4208-81e2-d278922d6cf9',11,100,1100),('fd27d3c5-eee4-4448-b502-9890475a6ed3','1e20a971-a4bf-494a-8e64-e4c66d8141b0','a9fd10ae-c56b-4bd7-beb0-2d2bcceafcef',40,400,16000),('ff629d7f-e1c9-4fd2-9f93-8f2aca8f43c3','1e20a971-a4bf-494a-8e64-e4c66d8141b0','040fdb66-a27c-48e2-8d16-296b44ce943b',5,3200,16000);
/*!40000 ALTER TABLE `b2b_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `b2b_orders`
--

DROP TABLE IF EXISTS `b2b_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `b2b_orders` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('PENDING','CONFIRMED','DISPATCHED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_amount` float DEFAULT NULL,
  `receipt_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `b2b_orders`
--

LOCK TABLES `b2b_orders` WRITE;
/*!40000 ALTER TABLE `b2b_orders` DISABLE KEYS */;
INSERT INTO `b2b_orders` VALUES ('136e3c1a-60db-4f71-b860-faa3b26774f7','Aarav Industries','9810012345','DISPATCHED',38500,NULL,'Rush delivery','2026-07-07 14:44:05'),('1e20a971-a4bf-494a-8e64-e4c66d8141b0','Esha Enterprises','9850056789','DISPATCHED',32000,NULL,'Export order','2026-07-07 14:44:05'),('6ed6a977-0815-4fd1-baef-14531153dc83','Devendra Tools','9840045678','DISPATCHED',41400,NULL,NULL,'2026-07-07 14:44:05'),('900db1ac-76df-4196-9784-65cfadb19f6c','Bharat Engineering','9820023456','CONFIRMED',45300,NULL,NULL,'2026-07-07 14:44:05'),('ebeae97f-dcbb-4a4b-9510-ef04645c7577','Chirag Fabrication','9830034567','PENDING',14000,NULL,'PO #PO-2026-0471','2026-07-07 14:44:05'),('f362440e-f85e-41af-a453-1ae7d513d333','Harsh','9872482406','DISPATCHED',1220,'receipts/B2B_ORDER_f362440e-f85e-41af-a453-1ae7d513d333_918299f57378488f848639f88868384a.jpeg','','2026-07-07 14:49:29');
/*!40000 ALTER TABLE `b2b_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_reports`
--

DROP TABLE IF EXISTS `daily_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_reports` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_date` date NOT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_date` (`report_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_reports`
--

LOCK TABLES `daily_reports` WRITE;
/*!40000 ALTER TABLE `daily_reports` DISABLE KEYS */;
INSERT INTO `daily_reports` VALUES ('774f9477-cbd8-436d-ade4-a85562f39624','2026-07-07','{\"date\": \"2026-07-07\", \"products_added\": 25, \"transactions\": {\"in\": 1268.0, \"out\": 1617.0, \"total\": 24}, \"orders\": {\"dispatched\": 3, \"pending\": 1, \"total\": 5}, \"vendor_jobs\": {\"issued\": 5, \"completed\": 5}, \"products_in_stock\": 25, \"stock_snapshot\": [{\"sku\": \"RM-002\", \"name\": \"Aluminium Ingot\", \"stock\": 600.0, \"unit\": \"kg\"}, {\"sku\": \"RM-007\", \"name\": \"Aluminium Sheet 2mm\", \"stock\": 450.0, \"unit\": \"kg\"}, {\"sku\": \"RM-003\", \"name\": \"Brass Rod 12mm\", \"stock\": 250.0, \"unit\": \"kg\"}, {\"sku\": \"RM-008\", \"name\": \"Brass Sheet 1mm\", \"stock\": 70.0, \"unit\": \"kg\"}, {\"sku\": \"FG-007\", \"name\": \"Control Panel Enclosure 400x300\", \"stock\": 45.0, \"unit\": \"pcs\"}, {\"sku\": \"FG-002\", \"name\": \"Conveyor Roller 150mm\", \"stock\": 180.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-004\", \"name\": \"Copper Wire 1.5mm\", \"stock\": 110.0, \"unit\": \"kg\"}, {\"sku\": \"RM-010\", \"name\": \"GI Sheet\", \"stock\": 750.0, \"unit\": \"kg\"}, {\"sku\": \"RM-013\", \"name\": \"Grinding Wheel 4 inch\", \"stock\": 200.0, \"unit\": \"pcs\"}, {\"sku\": \"FG-010\", \"name\": \"Guard Mesh Panel 1000x800\", \"stock\": 30.0, \"unit\": \"pcs\"}, {\"sku\": \"FG-009\", \"name\": \"Hopper Assembly 50kg\", \"stock\": 18.0, \"unit\": \"pcs\"}, {\"sku\": \"FG-001\", \"name\": \"Machine Base Frame 600x400\", \"stock\": 70.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-001\", \"name\": \"Mild Steel Plate 6mm\", \"stock\": 1700.0, \"unit\": \"kg\"}, {\"sku\": \"FG-004\", \"name\": \"Motor Mounting Plate\", \"stock\": 60.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-006\", \"name\": \"MS Angle 40x40\", \"stock\": 950.0, \"unit\": \"kg\"}, {\"sku\": \"RM-009\", \"name\": \"MS Pipe 2 inch\", \"stock\": 700.0, \"unit\": \"kg\"}, {\"sku\": \"RM-014\", \"name\": \"Nut Bolt M12x50mm\", \"stock\": 4000.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-011\", \"name\": \"Paint - Red Oxide\", \"stock\": 60.0, \"unit\": \"ltr\"}, {\"sku\": \"FG-006\", \"name\": \"Pneumatic Cylinder Bracket\", \"stock\": 160.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-015\", \"name\": \"PVC Insulation Tape\", \"stock\": 100.0, \"unit\": \"rolls\"}, {\"sku\": \"FG-008\", \"name\": \"Shaft Coupling 25mm\", \"stock\": 150.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-005\", \"name\": \"Stainless Steel Sheet 3mm\", \"stock\": 320.0, \"unit\": \"kg\"}, {\"sku\": \"FG-003\", \"name\": \"Support Bracket L-Type\", \"stock\": 150.0, \"unit\": \"pcs\"}, {\"sku\": \"FG-005\", \"name\": \"Vibratory Feeder Tray\", \"stock\": 13.0, \"unit\": \"pcs\"}, {\"sku\": \"RM-012\", \"name\": \"Welding Electrode 3.15mm\", \"stock\": 4800.0, \"unit\": \"pcs\"}]}','2026-07-07 14:44:05');
/*!40000 ALTER TABLE `daily_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('IN','OUT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` float NOT NULL,
  `reference_type` enum('PURCHASE','MANUFACTURING','B2B_ORDER','ADJUSTMENT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receipt_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `inventory_transactions_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES ('006b8fdb-ed15-4de3-81b9-43e0b5bc4b8c','d6d50b34-e185-4f86-8ef4-223b9a85aa89','OUT',200,'MANUFACTURING','95d328e2-d149-4add-ac5f-1c47687a4f5e',NULL,'Issued to vendor: Singh Engineering','2026-07-07 14:44:05'),('038a0a20-680b-47a8-b64d-4d6bd92cf3fc','c2ca6671-65f6-4477-ae4c-20a9040f5c5e','OUT',5,'B2B_ORDER','f362440e-f85e-41af-a453-1ae7d513d333','receipts/B2B_ORDER_f362440e-f85e-41af-a453-1ae7d513d333_918299f57378488f848639f88868384a.jpeg','Dispatched in order f362440e-f85e-41af-a453-1ae7d513d333','2026-07-07 14:52:31'),('08d2e04d-a5bb-4852-8379-799b14c40285','040fdb66-a27c-48e2-8d16-296b44ce943b','OUT',5,'B2B_ORDER','1e20a971-a4bf-494a-8e64-e4c66d8141b0',NULL,'Dispatched in order 1e20a971-a4bf-494a-8e64-e4c66d8141b0','2026-07-07 14:44:05'),('237a76c6-c303-4ca2-b019-7321fa477d0a','87eca360-ffe3-4287-8ff1-8047e6e9a09a','OUT',15,'B2B_ORDER','6ed6a977-0815-4fd1-baef-14531153dc83',NULL,'Dispatched in order 6ed6a977-0815-4fd1-baef-14531153dc83','2026-07-07 14:44:05'),('33ef1691-b9c8-4161-9fdf-c73d460be65e','c2ca6671-65f6-4477-ae4c-20a9040f5c5e','OUT',30,'MANUFACTURING','b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd',NULL,'Issued to vendor: Gupta Works','2026-07-07 14:44:05'),('3b21fde4-58a3-44e1-9643-dadc83f79b84','169a8be5-3f15-4208-81e2-d278922d6cf9','OUT',150,'MANUFACTURING','95d328e2-d149-4add-ac5f-1c47687a4f5e',NULL,'Issued to vendor: Singh Engineering','2026-07-07 14:44:05'),('3ddef62f-4641-4736-bb15-2e91181bbe99','4ea13f65-5077-4d7a-aca4-fa3b5998cf5d','IN',10,'ADJUSTMENT','ADJ-03734D67',NULL,'Purchased 10 ltr red oxide','2026-07-07 14:44:05'),('4336bb58-67fb-44d7-979b-4ed9854bdfaf','d6d50b34-e185-4f86-8ef4-223b9a85aa89','OUT',10,'MANUFACTURING','50dcda91-8083-404f-a4de-542e0b7399f3',NULL,'Issued to vendor: Rana kumar','2026-07-07 14:46:04'),('43fab198-7cf1-43f2-bec0-5fe56bfc81f9','d6b539c4-047c-4fa1-89e3-a13cbcdbe66b','OUT',100,'MANUFACTURING','7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06',NULL,'Issued to vendor: Kumar Machining','2026-07-07 14:44:05'),('4b5311e1-bf6f-4947-8c69-8d01326cc707','9bb5bbe5-8c4f-458d-bf75-798b212a47f5','OUT',300,'MANUFACTURING','8b762de1-a00a-453a-997b-7d21871cdfce',NULL,'Issued to vendor: Rana Fabrication','2026-07-07 14:44:05'),('4d8938fe-5bff-4a41-8a36-607e93bbb7a6','147f3989-5ccb-43a4-a5be-471dc1333f25','OUT',200,'MANUFACTURING','7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06',NULL,'Issued to vendor: Kumar Machining','2026-07-07 14:44:05'),('55245127-097f-48fd-b472-dae7ff50af31','040fdb66-a27c-48e2-8d16-296b44ce943b','IN',20,'MANUFACTURING','e8c174cc-058c-4f6a-8ce6-3c7e532cc137',NULL,'Received from vendor: Verma Fabricators','2026-07-07 14:44:05'),('5aaa32ce-8c44-46a8-bc3a-4af0caa1161d','a9fd10ae-c56b-4bd7-beb0-2d2bcceafcef','OUT',40,'B2B_ORDER','1e20a971-a4bf-494a-8e64-e4c66d8141b0',NULL,'Dispatched in order 1e20a971-a4bf-494a-8e64-e4c66d8141b0','2026-07-07 14:44:05'),('643347a8-6522-49f3-a8f0-9774bdccc95a','bcd6f86e-16e5-44cd-ae18-45903e84bdb4','IN',100,'MANUFACTURING','95d328e2-d149-4add-ac5f-1c47687a4f5e',NULL,'Received from vendor: Singh Engineering','2026-07-07 14:44:05'),('7848805d-8d6f-483d-8f11-5e3de55c0db6','b737492a-0f27-4ec5-998a-a4453163dbb4','OUT',5,'B2B_ORDER','136e3c1a-60db-4f71-b860-faa3b26774f7',NULL,'Dispatched in order 136e3c1a-60db-4f71-b860-faa3b26774f7','2026-07-07 14:44:05'),('80e8df57-622c-4e2c-b89b-4b69afefdfa9','560119b0-0aca-4e58-b0d8-12d827e6c20a','OUT',50,'MANUFACTURING','b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd',NULL,'Issued to vendor: Gupta Works','2026-07-07 14:44:05'),('9083c29c-e0f2-498a-9ee0-21d166b3a65c','55fbb87f-7076-4400-801f-7714da92cd66','OUT',18,'ADJUSTMENT','ADJ-98A289A4','receipts/ADJUSTMENT_55fbb87f-7076-4400-801f-7714da92cd66_abde3c5e1c3c4f1eb01f1a4ca93872b9.jpeg',NULL,'2026-07-07 15:13:07'),('98c4e69c-94a2-424f-a669-01754f86711c','f421f2f9-4840-4490-ac8b-a599346de14b','OUT',40,'MANUFACTURING','e8c174cc-058c-4f6a-8ce6-3c7e532cc137',NULL,'Issued to vendor: Verma Fabricators','2026-07-07 14:44:05'),('a8277810-2740-4e9b-b56f-45f901ca02b6','2b72e803-b500-4d61-87c8-362f1151f476','OUT',200,'ADJUSTMENT','ADJ-66024A50',NULL,'Returned damaged electrodes','2026-07-07 14:44:05'),('a8934427-d011-4d79-959d-7e7a6fff1b30','169a8be5-3f15-4208-81e2-d278922d6cf9','OUT',11,'B2B_ORDER','f362440e-f85e-41af-a453-1ae7d513d333','receipts/B2B_ORDER_f362440e-f85e-41af-a453-1ae7d513d333_918299f57378488f848639f88868384a.jpeg','Dispatched in order f362440e-f85e-41af-a453-1ae7d513d333','2026-07-07 14:52:31'),('a95ff52c-ab8a-4db6-9e6d-6e5d52a7f090','b737492a-0f27-4ec5-998a-a4453163dbb4','IN',50,'MANUFACTURING','8b762de1-a00a-453a-997b-7d21871cdfce',NULL,'Received from vendor: Rana Fabrication','2026-07-07 14:44:05'),('b40e9001-01b7-42c3-83e4-c678e51de732','55fbb87f-7076-4400-801f-7714da92cd66','IN',8,'MANUFACTURING','7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06',NULL,'Received from vendor: Kumar Machining','2026-07-07 14:44:05'),('cdbeb832-d4d6-495a-ade9-c8fde025265f','a9fd10ae-c56b-4bd7-beb0-2d2bcceafcef','IN',80,'MANUFACTURING','b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd',NULL,'Received from vendor: Gupta Works','2026-07-07 14:44:05'),('d520b389-e777-44b7-84c1-1a33874b07a2','d6d50b34-e185-4f86-8ef4-223b9a85aa89','IN',10,'MANUFACTURING','50dcda91-8083-404f-a4de-542e0b7399f3','receipts/VENDOR_50dcda91-8083-404f-a4de-542e0b7399f3_37d3ea8fd37a4220baf63634b16d0055.jpeg','Received from vendor: Rana kumar','2026-07-07 14:47:10'),('d9107b31-d083-4dbd-8fe9-a90e27ce96bf','850e8edb-867e-4bdf-9d33-4605b9765e9f','IN',1000,'ADJUSTMENT','ADJ-3736EE22',NULL,'Additional nut bolts received','2026-07-07 14:44:05'),('dbfbde81-43c5-4d38-9618-01e9eaaffac6','363e52ca-1986-4368-8fd3-805fe5bdab32','OUT',80,'MANUFACTURING','e8c174cc-058c-4f6a-8ce6-3c7e532cc137',NULL,'Issued to vendor: Verma Fabricators','2026-07-07 14:44:05'),('ec4b7eae-7377-4e2d-a598-62a314be6033','7d23e1c2-e0cd-4936-9746-8c4696c9e786','OUT',50,'B2B_ORDER','136e3c1a-60db-4f71-b860-faa3b26774f7',NULL,'Dispatched in order 136e3c1a-60db-4f71-b860-faa3b26774f7','2026-07-07 14:44:05'),('f9388606-249f-452d-9866-a6900bd8e794','d6b539c4-047c-4fa1-89e3-a13cbcdbe66b','OUT',150,'MANUFACTURING','8b762de1-a00a-453a-997b-7d21871cdfce',NULL,'Issued to vendor: Rana Fabrication','2026-07-07 14:44:05'),('f9e965e8-e873-41ed-855e-f4ca49fc0914','581fc738-b060-4a3c-8bf1-b454f483701f','OUT',2,'B2B_ORDER','6ed6a977-0815-4fd1-baef-14531153dc83',NULL,'Dispatched in order 6ed6a977-0815-4fd1-baef-14531153dc83','2026-07-07 14:44:05');
/*!40000 ALTER TABLE `inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `current_stock` float DEFAULT NULL,
  `unit_price` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `is_critical` tinyint(1) NOT NULL DEFAULT '0',
  `reorder_threshold` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES ('040fdb66-a27c-48e2-8d16-296b44ce943b','FG-007','Control Panel Enclosure 400x300','Finished Good','pcs',45,2800,'2026-07-07 14:44:05',0,NULL),('147f3989-5ccb-43a4-a5be-471dc1333f25','RM-009','MS Pipe 2 inch','Raw Material','kg',700,65,'2026-07-07 14:44:05',0,NULL),('169a8be5-3f15-4208-81e2-d278922d6cf9','RM-007','Aluminium Sheet 2mm','Raw Material','kg',439,110,'2026-07-07 14:44:04',0,NULL),('18c352bc-bd18-40e2-a581-daa23e539b98','FG-008','Shaft Coupling 25mm','Finished Good','pcs',150,220,'2026-07-07 14:44:05',0,NULL),('2b72e803-b500-4d61-87c8-362f1151f476','RM-012','Welding Electrode 3.15mm','Raw Material','pcs',4800,8,'2026-07-07 14:44:05',0,NULL),('363e52ca-1986-4368-8fd3-805fe5bdab32','RM-005','Stainless Steel Sheet 3mm','Raw Material','kg',320,95,'2026-07-07 14:44:04',0,NULL),('4ea13f65-5077-4d7a-aca4-fa3b5998cf5d','RM-011','Paint - Red Oxide','Raw Material','ltr',60,320,'2026-07-07 14:44:05',0,NULL),('55fbb87f-7076-4400-801f-7714da92cd66','FG-009','Hopper Assembly 50kg','Finished Good','pcs',0,8500,'2026-07-07 14:44:05',0,NULL),('560119b0-0aca-4e58-b0d8-12d827e6c20a','RM-003','Brass Rod 12mm','Raw Material','kg',250,180,'2026-07-07 14:44:04',0,NULL),('581fc738-b060-4a3c-8bf1-b454f483701f','FG-005','Vibratory Feeder Tray','Finished Good','pcs',13,6500,'2026-07-07 14:44:05',0,NULL),('767d4f50-241a-4843-8c96-976552e7372e','RM-015','PVC Insulation Tape','Raw Material','rolls',100,35,'2026-07-07 14:44:05',0,NULL),('7d23e1c2-e0cd-4936-9746-8c4696c9e786','FG-003','Support Bracket L-Type','Finished Good','pcs',150,180,'2026-07-07 14:44:05',0,NULL),('83a27600-c41c-44ba-88f1-bfd9fe3c4678','FG-004','Motor Mounting Plate','Finished Good','pcs',60,1200,'2026-07-07 14:44:05',0,NULL),('850e8edb-867e-4bdf-9d33-4605b9765e9f','RM-014','Nut Bolt M12x50mm','Raw Material','pcs',4000,6,'2026-07-07 14:44:05',0,NULL),('87eca360-ffe3-4287-8ff1-8047e6e9a09a','FG-010','Guard Mesh Panel 1000x800','Finished Good','pcs',30,1600,'2026-07-07 14:44:05',0,NULL),('9bb5bbe5-8c4f-458d-bf75-798b212a47f5','RM-001','Mild Steel Plate 6mm','Raw Material','kg',1700,45,'2026-07-07 14:44:04',0,NULL),('a1d5ad26-f5bb-49d5-a702-b2130302fc5b','RM-010','GI Sheet','Raw Material','kg',750,78,'2026-07-07 14:44:05',0,NULL),('a9fd10ae-c56b-4bd7-beb0-2d2bcceafcef','FG-006','Pneumatic Cylinder Bracket','Finished Good','pcs',160,340,'2026-07-07 14:44:05',0,NULL),('b737492a-0f27-4ec5-998a-a4453163dbb4','FG-001','Machine Base Frame 600x400','Finished Good','pcs',70,4500,'2026-07-07 14:44:05',0,NULL),('bcd6f86e-16e5-44cd-ae18-45903e84bdb4','FG-002','Conveyor Roller 150mm','Finished Good','pcs',180,850,'2026-07-07 14:44:05',0,NULL),('c2ca6671-65f6-4477-ae4c-20a9040f5c5e','RM-008','Brass Sheet 1mm','Raw Material','kg',65,250,'2026-07-07 14:44:04',0,NULL),('d6b539c4-047c-4fa1-89e3-a13cbcdbe66b','RM-006','MS Angle 40x40','Raw Material','kg',950,55,'2026-07-07 14:44:04',0,NULL),('d6d50b34-e185-4f86-8ef4-223b9a85aa89','RM-002','Aluminium Ingot','Raw Material','kg',600,120,'2026-07-07 14:44:04',0,NULL),('e5689b17-c4ac-46eb-934b-c3778886234a','RM-013','Grinding Wheel 4 inch','Raw Material','pcs',200,45,'2026-07-07 14:44:05',0,NULL),('f421f2f9-4840-4490-ac8b-a599346de14b','RM-004','Copper Wire 1.5mm','Raw Material','kg',110,520,'2026-07-07 14:44:04',0,NULL);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reorder_requests`
--

DROP TABLE IF EXISTS `reorder_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reorder_requests` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` float NOT NULL,
  `supplier_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('PENDING','RECEIVED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `receipt_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `reorder_requests_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reorder_requests`
--

LOCK TABLES `reorder_requests` WRITE;
/*!40000 ALTER TABLE `reorder_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `reorder_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor_job_work_items`
--

DROP TABLE IF EXISTS `vendor_job_work_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_job_work_items` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `job_work_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `job_work_id` (`job_work_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `vendor_job_work_items_ibfk_1` FOREIGN KEY (`job_work_id`) REFERENCES `vendor_job_works` (`id`),
  CONSTRAINT `vendor_job_work_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_job_work_items`
--

LOCK TABLES `vendor_job_work_items` WRITE;
/*!40000 ALTER TABLE `vendor_job_work_items` DISABLE KEYS */;
INSERT INTO `vendor_job_work_items` VALUES ('087d1f25-5c4c-407e-99cd-08b3b0eb7318','95d328e2-d149-4add-ac5f-1c47687a4f5e','RAW','d6d50b34-e185-4f86-8ef4-223b9a85aa89',200),('0d851d21-11b9-46fe-b4de-1052e899cc76','8b762de1-a00a-453a-997b-7d21871cdfce','RAW','9bb5bbe5-8c4f-458d-bf75-798b212a47f5',300),('0dc1f35f-7188-487d-90e2-84aca5fe4d6b','7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06','FINISHED','55fbb87f-7076-4400-801f-7714da92cd66',8),('471eaf7e-06a8-4996-952f-a158c82bb7ac','95d328e2-d149-4add-ac5f-1c47687a4f5e','FINISHED','bcd6f86e-16e5-44cd-ae18-45903e84bdb4',100),('6ed4002a-ed41-451d-95b1-930d03f0358c','b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd','RAW','560119b0-0aca-4e58-b0d8-12d827e6c20a',50),('6faedf23-cb00-4288-869f-bdd82471ee49','50dcda91-8083-404f-a4de-542e0b7399f3','RAW','d6d50b34-e185-4f86-8ef4-223b9a85aa89',10),('72f4abe3-163e-45fe-a901-9abb530016bd','95d328e2-d149-4add-ac5f-1c47687a4f5e','RAW','169a8be5-3f15-4208-81e2-d278922d6cf9',150),('952e7fab-743b-4c6d-ba1a-886a117c93c5','e8c174cc-058c-4f6a-8ce6-3c7e532cc137','RAW','363e52ca-1986-4368-8fd3-805fe5bdab32',80),('9a7f6779-6c49-4ff9-9dab-9bcdbf6ab978','7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06','RAW','147f3989-5ccb-43a4-a5be-471dc1333f25',200),('a9e0fbfd-eea0-4b6f-b9e2-fc51f68a4a70','e8c174cc-058c-4f6a-8ce6-3c7e532cc137','RAW','f421f2f9-4840-4490-ac8b-a599346de14b',40),('aa53516b-7148-4306-91e0-2b097cce8b6c','e8c174cc-058c-4f6a-8ce6-3c7e532cc137','FINISHED','040fdb66-a27c-48e2-8d16-296b44ce943b',20),('b20a3dd2-3295-48de-93c5-9a4ec1bb4184','b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd','RAW','c2ca6671-65f6-4477-ae4c-20a9040f5c5e',30),('c925fb1d-b838-4602-ba5a-1a6ee3036cfc','50dcda91-8083-404f-a4de-542e0b7399f3','FINISHED','d6d50b34-e185-4f86-8ef4-223b9a85aa89',10),('cb46aaa1-0636-4107-b068-3cfe223e2e66','b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd','FINISHED','a9fd10ae-c56b-4bd7-beb0-2d2bcceafcef',80),('db2f0150-9fb3-48e9-8df0-9c09ea341f3a','8b762de1-a00a-453a-997b-7d21871cdfce','RAW','d6b539c4-047c-4fa1-89e3-a13cbcdbe66b',150),('dda7ae63-c192-483a-9829-9525ba91df25','7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06','RAW','d6b539c4-047c-4fa1-89e3-a13cbcdbe66b',100),('e90c01e2-9de2-4a04-be1e-294140671582','8b762de1-a00a-453a-997b-7d21871cdfce','FINISHED','b737492a-0f27-4ec5-998a-a4453163dbb4',50);
/*!40000 ALTER TABLE `vendor_job_work_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor_job_works`
--

DROP TABLE IF EXISTS `vendor_job_works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_job_works` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vendor_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('ISSUED','PARTIALLY_RECEIVED','COMPLETED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `issued_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `receipt_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_job_works`
--

LOCK TABLES `vendor_job_works` WRITE;
/*!40000 ALTER TABLE `vendor_job_works` DISABLE KEYS */;
INSERT INTO `vendor_job_works` VALUES ('50dcda91-8083-404f-a4de-542e0b7399f3','Rana kumar','COMPLETED','2026-07-07 14:46:04','2026-07-07 14:47:10','receipts/VENDOR_50dcda91-8083-404f-a4de-542e0b7399f3_37d3ea8fd37a4220baf63634b16d0055.jpeg',''),('7b1fb11e-6c1a-483b-9fc8-8eaaa82cdb06','Kumar Machining','COMPLETED','2026-07-07 14:44:05','2026-07-07 14:44:05',NULL,'Hopper assembly job'),('8b762de1-a00a-453a-997b-7d21871cdfce','Rana Fabrication','COMPLETED','2026-07-07 14:44:05','2026-07-07 14:44:05',NULL,'Fabricate 50 machine base frames'),('95d328e2-d149-4add-ac5f-1c47687a4f5e','Singh Engineering','COMPLETED','2026-07-07 14:44:05','2026-07-07 14:44:05',NULL,'Make 100 conveyor rollers'),('b3531c5f-287d-4832-b4bc-d1bdaeb1b4cd','Gupta Works','COMPLETED','2026-07-07 14:44:05','2026-07-07 14:44:05',NULL,'Brass bracket order'),('e8c174cc-058c-4f6a-8ce6-3c7e532cc137','Verma Fabricators','COMPLETED','2026-07-07 14:44:05','2026-07-07 14:44:05',NULL,'Control panel enclosures');
/*!40000 ALTER TABLE `vendor_job_works` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-08 21:29:59
