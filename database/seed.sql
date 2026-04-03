-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: infybot_db
-- ------------------------------------------------------
-- Server version	8.0.45

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

--
-- Table structure for table `access_logs`
--

DROP TABLE IF EXISTS `access_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `access_logs` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `admin_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `access_level` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_access_logs_admin_id` (`admin_id`),
  KEY `idx_access_logs_user_id` (`user_id`),
  KEY `idx_access_logs_granted_at` (`granted_at`),
  CONSTRAINT `fk_access_logs_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_access_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access_logs`
--

LOCK TABLES `access_logs` WRITE;
/*!40000 ALTER TABLE `access_logs` DISABLE KEYS */;
INSERT INTO `access_logs` VALUES ('23666ae0-1715-432f-865d-f8203e23569e','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','none','2026-03-31 09:10:59'),('324569eb-3e82-42e7-a011-3742f5f05ba0','11111111-1111-1111-1111-111111111111','22222222-2222-2222-2222-222222222222','edit','2026-03-31 08:32:23'),('3a54e158-65fa-47fb-89b4-265c1a4c100d','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','edit','2026-03-31 08:11:02'),('5af8c7f1-afa0-4d8a-921d-3fc40510f396','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','edit','2026-03-31 07:57:09'),('93e3fe4b-2656-485f-aa77-9bda9e58d3a1','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','none','2026-03-31 07:58:01'),('ab04a9e0-596a-44a6-b5f2-07e90e937875','11111111-1111-1111-1111-111111111111','d58d621a-5700-4efa-b864-a1cd528562a9','view','2026-03-31 09:09:25'),('al-001','11111111-1111-1111-1111-111111111111','22222222-2222-2222-2222-222222222222','view','2026-03-30 05:26:31'),('al-002','11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333','view','2026-03-30 05:26:31'),('al-003','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','edit','2026-03-30 05:26:31'),('al-004','11111111-1111-1111-1111-111111111111','55555555-5555-5555-5555-555555555555','none','2026-03-30 05:26:31'),('c0d54c8b-b32a-4056-9f4b-6136b00a1466','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','edit','2026-03-31 09:15:10'),('f502715d-70c9-4ef9-a209-735882eaaa13','11111111-1111-1111-1111-111111111111','44444444-4444-4444-4444-444444444444','view','2026-03-31 08:10:32');
/*!40000 ALTER TABLE `access_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `account_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_number` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_type` enum('checking','savings','salary','current','business') COLLATE utf8mb4_unicode_ci NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INR',
  `status` enum('active','inactive','frozen','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `branch_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ifsc_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `account_number` (`account_number`),
  KEY `idx_accounts_user_id` (`user_id`),
  KEY `idx_accounts_status` (`status`),
  CONSTRAINT `fk_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_accounts_balance_non_negative` CHECK ((`balance` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'22222222-2222-2222-2222-222222222222','200000000001','savings',85250.75,'INR','active','Aditya Bank Main Branch','ADBK0001001','2026-03-30 05:26:31','2026-03-30 07:10:27'),(2,'33333333-3333-3333-3333-333333333333','200000000002','salary',45200.00,'INR','active','Aditya Bank Main Branch','ADBK0001001','2026-03-30 05:26:31','2026-03-30 07:10:27'),(3,'44444444-4444-4444-4444-444444444444','200000000003','current',128900.50,'INR','active','Aditya Bank City Branch','ADBK0001002','2026-03-30 05:26:31','2026-03-30 07:10:27'),(4,'55555555-5555-5555-5555-555555555555','200000000004','savings',310500.25,'INR','active','Aditya Bank Pune Branch','ADBK0001003','2026-03-30 05:26:31','2026-03-30 07:10:27');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alerts`
--

DROP TABLE IF EXISTS `alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alerts` (
  `alert_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alert_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `threshold_amount` decimal(15,2) DEFAULT NULL,
  `is_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`alert_id`),
  KEY `idx_alerts_user_id` (`user_id`),
  CONSTRAINT `fk_alerts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alerts`
--

LOCK TABLES `alerts` WRITE;
/*!40000 ALTER TABLE `alerts` DISABLE KEYS */;
INSERT INTO `alerts` VALUES (1,'22222222-2222-2222-2222-222222222222','low_balance',5000.00,1,'2026-03-30 05:26:31'),(2,'33333333-3333-3333-3333-333333333333','high_debit',10000.00,1,'2026-03-30 05:26:31'),(3,'55555555-5555-5555-5555-555555555555','investment_change',NULL,1,'2026-03-30 05:26:31'),(4,'22222222-2222-2222-2222-222222222222','low_balance',5000.00,1,'2026-03-30 05:44:39'),(5,'33333333-3333-3333-3333-333333333333','high_debit',10000.00,1,'2026-03-30 05:44:39'),(6,'55555555-5555-5555-5555-555555555555','investment_change',NULL,1,'2026-03-30 05:44:39');
/*!40000 ALTER TABLE `alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `atms`
--

DROP TABLE IF EXISTS `atms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atms` (
  `atm_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `location_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_24hr` tinyint(1) NOT NULL DEFAULT '1',
  `features` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('operational','maintenance','offline') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'operational',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`atm_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `atms`
--

LOCK TABLES `atms` WRITE;
/*!40000 ALTER TABLE `atms` DISABLE KEYS */;
INSERT INTO `atms` VALUES (1,'Aditya Bank ATM - MG Road','MG Road, Pune','Pune','Maharashtra',1,'Cash Withdrawal, Deposit, Mini Statement','operational','2026-03-30 05:26:32'),(2,'Aditya Bank ATM - FC Road','FC Road, Pune','Pune','Maharashtra',1,'Cash Withdrawal, Balance Inquiry','operational','2026-03-30 05:26:32'),(3,'Aditya Bank ATM - Solapur Station','Station Road, Solapur','Solapur','Maharashtra',1,'Cash Withdrawal, Deposit','maintenance','2026-03-30 05:26:32'),(4,'Aditya Bank ATM - MG Road','MG Road, Pune','Pune','Maharashtra',1,'Cash Withdrawal, Deposit, Mini Statement','operational','2026-03-30 05:44:39'),(5,'Aditya Bank ATM - FC Road','FC Road, Pune','Pune','Maharashtra',1,'Cash Withdrawal, Balance Inquiry','operational','2026-03-30 05:44:39'),(6,'Aditya Bank ATM - Solapur Station','Station Road, Solapur','Solapur','Maharashtra',1,'Cash Withdrawal, Deposit','maintenance','2026-03-30 05:44:39');
/*!40000 ALTER TABLE `atms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bills` (
  `bill_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `biller_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bill_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `due_date` date DEFAULT NULL,
  `status` enum('pending','paid','overdue','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bill_id`),
  KEY `idx_bills_user_id` (`user_id`),
  KEY `idx_bills_status` (`status`),
  CONSTRAINT `fk_bills_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (1,'22222222-2222-2222-2222-222222222222','MSEDCL Electricity','Electricity',1850.00,'2026-04-03','pending',NULL,'2026-03-30 05:26:31'),(2,'33333333-3333-3333-3333-333333333333','Airtel Broadband','Internet',999.00,'2026-03-28','overdue',NULL,'2026-03-30 05:26:31'),(3,'55555555-5555-5555-5555-555555555555','Jio Postpaid','Mobile',799.00,'2026-03-22','paid','2026-03-24 05:26:31','2026-03-30 05:26:31'),(4,'22222222-2222-2222-2222-222222222222','MSEDCL Electricity','Electricity',1850.00,'2026-04-03','pending',NULL,'2026-03-30 05:44:39'),(5,'33333333-3333-3333-3333-333333333333','Airtel Broadband','Internet',999.00,'2026-03-28','overdue',NULL,'2026-03-30 05:44:39'),(6,'55555555-5555-5555-5555-555555555555','Jio Postpaid','Mobile',799.00,'2026-03-22','paid','2026-03-24 05:44:39','2026-03-30 05:44:39');
/*!40000 ALTER TABLE `bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `branch_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `branch_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opening_time` time DEFAULT '09:00:00',
  `closing_time` time DEFAULT '17:00:00',
  `has_atm` tinyint(1) NOT NULL DEFAULT '1',
  `has_locker` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('open','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'Aditya Bank Main Branch','MG Road, Pune','Pune','Maharashtra','02040001111','09:00:00','17:00:00',1,1,'open','2026-03-30 05:26:31'),(2,'Aditya Bank City Branch','FC Road, Pune','Pune','Maharashtra','02040002222','09:30:00','17:30:00',1,0,'open','2026-03-30 05:26:31'),(3,'Aditya Bank Solapur Branch','Station Road, Solapur','Solapur','Maharashtra','02174000333','09:00:00','17:00:00',1,1,'open','2026-03-30 05:26:31'),(4,'Aditya Bank Main Branch','MG Road, Pune','Pune','Maharashtra','02040001111','09:00:00','17:00:00',1,1,'open','2026-03-30 05:44:39'),(5,'Aditya Bank City Branch','FC Road, Pune','Pune','Maharashtra','02040002222','09:30:00','17:30:00',1,0,'open','2026-03-30 05:44:39'),(6,'Aditya Bank Solapur Branch','Station Road, Solapur','Solapur','Maharashtra','02174000333','09:00:00','17:00:00',1,1,'open','2026-03-30 05:44:39');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cards`
--

DROP TABLE IF EXISTS `cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cards` (
  `card_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `card_type` enum('debit','credit') COLLATE utf8mb4_unicode_ci NOT NULL,
  `card_number` varchar(19) COLLATE utf8mb4_unicode_ci NOT NULL,
  `card_network` enum('Visa','Mastercard','RuPay','Amex') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Visa',
  `expiry_date` date NOT NULL,
  `cvv` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','frozen','blocked','expired') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `credit_limit` decimal(15,2) NOT NULL DEFAULT '0.00',
  `available_credit` decimal(15,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`card_id`),
  UNIQUE KEY `card_number` (`card_number`),
  KEY `idx_cards_user_id` (`user_id`),
  KEY `idx_cards_status` (`status`),
  CONSTRAINT `fk_cards_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_cards_credit_non_negative` CHECK (((`credit_limit` >= 0) and (`available_credit` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cards`
--

LOCK TABLES `cards` WRITE;
/*!40000 ALTER TABLE `cards` DISABLE KEYS */;
INSERT INTO `cards` VALUES (1,'22222222-2222-2222-2222-222222222222','debit','4111111111111111','Visa','2028-12-31','123','active',0.00,0.00,'2026-03-30 05:26:31','2026-03-30 05:26:31'),(2,'33333333-3333-3333-3333-333333333333','credit','5555555555554444','Mastercard','2027-10-31','456','frozen',100000.00,72500.00,'2026-03-30 05:26:31','2026-03-30 07:13:04'),(3,'55555555-5555-5555-5555-555555555555','credit','4111222233334444','Visa','2029-08-31','789','active',150000.00,140000.00,'2026-03-30 05:26:31','2026-03-30 05:26:31');
/*!40000 ALTER TABLE `cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_sessions`
--

DROP TABLE IF EXISTS `chat_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_sessions` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'New Conversation',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_sessions_user_id` (`user_id`),
  KEY `idx_chat_sessions_updated_at` (`updated_at`),
  CONSTRAINT `fk_chat_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_sessions`
--

LOCK TABLES `chat_sessions` WRITE;
/*!40000 ALTER TABLE `chat_sessions` DISABLE KEYS */;
INSERT INTO `chat_sessions` VALUES ('01faff73-9a77-4361-a787-5f0925a4f8b2','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:01:13','2026-03-30 06:01:13'),('03057bbe-721c-4355-9eef-38c0624e73e3','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:12:24','2026-03-31 09:12:24'),('0584982e-1457-41b6-80fa-41e74cecc214','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:19','2026-03-31 09:19:19'),('064e4665-ecd1-4429-aac0-0696f08eb682','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:31:43','2026-03-31 08:31:43'),('074cfc7a-fac1-4be9-a1fc-a1994e32bf5f','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:48','2026-03-31 09:17:48'),('07d1acaf-270c-4670-a1ce-70d947465de9','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 07:58:31','2026-03-31 07:58:31'),('0a9bf7ab-4d72-440d-ad45-9ae6b4aaa229','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 07:52:12','2026-03-31 07:52:12'),('0b659e87-887d-4b34-a2ac-dfdb52cad793','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:31:59','2026-03-31 08:31:59'),('0bdd7fd1-84af-4dad-8816-05eded363771','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:18','2026-03-31 09:19:18'),('0cecf05a-e9a4-4566-afc4-f8d39dd2ee3a','e922f847-7f66-4d84-9c43-bdc18b28c3d2','New Conversation',1,'2026-03-31 08:10:03','2026-03-31 08:10:03'),('0de341da-1179-4210-b755-cca47d653147','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:02:56','2026-03-31 09:02:56'),('0f7515c7-727e-4fee-a6ce-b7f443adae2a','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 07:58:31','2026-03-31 07:58:31'),('1304c366-d1eb-4f19-9438-7978dd611511','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 11:11:05','2026-03-31 11:11:11'),('157249cc-1fc9-4490-9566-734a274997d8','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:07:03','2026-03-30 06:07:03'),('16ae923b-3276-4d71-8f0e-0f86ca4011fa','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 06:00:40','2026-03-30 06:00:40'),('1756d63a-caec-40d6-931d-804f224e4a89','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:33:58','2026-03-30 06:33:58'),('19abee0e-4f84-4757-9f64-b204eba7a878','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:44','2026-03-30 09:13:48'),('1a97a05e-b021-4afb-9da1-5a0ff830e68a','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:35','2026-03-30 09:13:38'),('1e45845f-b595-46cf-9bf2-b4883d057ef9','11111111-1111-1111-1111-111111111111','How do I reset my password?',1,'2026-03-30 06:00:40','2026-03-30 06:00:41'),('1f0a9c96-27d8-46fe-94cf-529f402b2188','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-04-02 14:23:06','2026-04-02 14:23:21'),('21339a49-deee-46ea-b983-f8a2a40e039a','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:14:51','2026-03-31 09:14:51'),('253b0a21-2331-449e-8f75-514fccaa779a','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:50','2026-03-31 09:09:50'),('254362d2-11d8-4781-85a7-0b7a8edac255','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:32:46','2026-03-30 06:32:46'),('267fe89b-ee2f-4a9c-8c64-8fdb0f4a1e3c','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:13:07','2026-03-31 09:13:07'),('28c4e91e-f5b6-4da6-abdb-f2c0cf2a6ffe','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:11:17','2026-03-31 09:11:17'),('299bc817-a604-4ef4-aed2-895c1ce982fa','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:15:14','2026-03-31 09:15:14'),('29e28989-806c-4d8d-98a1-32ed5df0282a','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:06:54','2026-03-31 09:06:54'),('2a0e681a-4879-4fdc-b8a9-5d496a275a92','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:31:56','2026-03-30 08:31:56'),('2a296618-e179-4469-be25-d75b33e48993','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:11:19','2026-03-31 09:11:19'),('2ab42aa7-8e9e-43c1-b5f2-4f419792ce54','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:16:53','2026-03-31 09:16:53'),('2add7f7c-f5a9-4756-8afd-0c0f4c1d754b','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:12:14','2026-03-31 08:12:14'),('2bfd770a-25b8-4480-8a83-1018388f5ff0','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:48','2026-03-31 09:17:48'),('2ea091e6-cb84-4aae-a9ca-174d7a1cee5c','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:13:07','2026-03-31 09:13:07'),('2efef7b4-206c-4b3a-8668-fe2e82c1b14a','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:18','2026-03-31 09:19:18'),('2fa59496-1d71-4625-b526-867d1118d189','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 06:43:24','2026-03-30 06:43:24'),('344813f3-2e53-4114-a5be-2e798f39dff0','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:35','2026-03-30 09:13:35'),('34f6b4f7-e3e9-41e6-9db6-43e38d79d663','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 06:00:28','2026-03-30 06:00:28'),('353473fb-f268-46f0-8712-8c07c23ce1a6','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:10:43','2026-03-31 08:10:43'),('3606bf79-5826-4d9b-80aa-62178b5ce56c','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 13:42:05','2026-03-31 13:42:05'),('3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 11:11:28','2026-03-31 11:13:22'),('388999bb-e313-4708-befb-373f2e72b11d','d58d621a-5700-4efa-b864-a1cd528562a9','New Conversation',1,'2026-03-31 09:14:43','2026-03-31 09:14:43'),('38cdb5a9-fa05-4fda-9a9b-bd05bfc58bcd','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:43','2026-03-31 09:17:43'),('39d08c4c-9281-45d2-997b-dd8f62532258','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:32:53','2026-03-30 06:32:53'),('3bbf2917-5609-42cf-80d6-3722da1f1ec2','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-04-02 14:22:39','2026-04-02 14:22:39'),('3bfe949c-e9ef-4157-b4b4-647d3ba7cb3b','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:16','2026-03-31 09:19:16'),('3e06a6dd-783d-43f7-9ee9-96ff289c164a','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 11:11:28','2026-03-31 11:11:28'),('3e4fafb5-037c-4405-be9f-ed7e97cd89c8','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:11:17','2026-03-31 09:11:17'),('3f9f2528-3da6-41a6-aabe-2eb273b916c5','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:33:50','2026-03-30 08:33:50'),('40afdfad-12f9-484a-9cc1-ceb40f31bf9a','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:30','2026-03-31 09:09:30'),('435495a7-4b6b-4880-b148-c35469b3089b','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:02:56','2026-03-31 09:02:56'),('43b22ee6-b5e0-441a-86eb-db6e56b4482f','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 08:14:58','2026-03-31 08:14:58'),('459bd9d9-e018-46e0-bc10-57b2a45e51c0','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:11:26','2026-03-31 09:11:26'),('4673f4b8-801c-480c-a59f-28a0e8008430','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 08:32:31','2026-03-31 08:32:31'),('4ac0a125-8c7c-4696-aee6-6d02f7620a9a','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:11:21','2026-03-30 06:11:21'),('4f70f8a2-9f1b-44fc-8b58-e1f177495a15','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 07:26:36','2026-03-31 07:26:36'),('508c420d-91c8-4e21-a4e9-bac5990bc9a6','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:19','2026-03-31 09:19:19'),('50cf711c-a078-4cf6-a3af-00f7ffcc76fe','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:08','2026-03-31 09:09:08'),('50e2f91a-8152-47b3-9719-f0893e0a6273','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:12:14','2026-03-31 08:12:14'),('5191c1b5-98b1-485a-b905-5a04932a7f04','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 13:41:28','2026-03-31 13:41:39'),('51d9b84c-7ed1-47eb-b353-154f23712257','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:33:50','2026-03-30 08:33:54'),('52ffeb49-0de9-4b30-adf1-aecfbbf7dd51','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 05:43:05','2026-03-30 05:43:05'),('539d0a65-0852-455f-ab0b-78055f5cc7dc','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:13:17','2026-03-31 09:13:17'),('559bef97-0398-4dc7-b1b8-97d82e3a8355','d58d621a-5700-4efa-b864-a1cd528562a9','New Conversation',1,'2026-03-31 07:50:37','2026-03-31 07:50:37'),('56487fd9-4ce2-414d-b1d5-d9c2446d20dc','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:11:27','2026-03-31 09:11:27'),('567be02f-be63-4bd0-86e3-33cdb503953a','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:44','2026-03-30 09:13:44'),('57329603-adb2-46e2-9e64-6e416ae32f21','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:12:01','2026-03-31 08:12:01'),('59a5d190-34b0-4769-98a4-82c17c273502','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:31:43','2026-03-31 08:31:43'),('5d101391-930b-45c8-9e9e-87ed924e7943','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:10:43','2026-03-31 08:10:43'),('5dd15459-c3ee-4540-9d84-c87f5b63be2d','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:48','2026-03-31 09:17:48'),('60d68df2-98e9-44dc-95f0-bb516fc2fd16','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:13','2026-03-30 09:13:13'),('6496126f-05ff-4b60-a253-d7113c914f82','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:17','2026-03-31 09:19:17'),('65457ba6-53db-4404-bf51-2fb143e7cdbb','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:47','2026-03-31 09:17:47'),('6716a154-52ca-472d-8a3f-3595041bcb2f','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:31:56','2026-03-30 08:31:56'),('67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 06:43:24','2026-03-30 06:44:20'),('68ea2c13-fff7-4bd1-94db-d7eb5e71d81c','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 08:32:31','2026-03-31 08:32:31'),('6a285ba4-2630-4fe9-ab4b-a82d1f13e982','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 07:46:50','2026-03-31 07:46:50'),('6b6f86c1-1619-4dda-a15c-2d326cbdae17','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:02:50','2026-03-31 09:02:50'),('6c1426f6-58d8-4ec4-936b-b55210de6d57','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:32:06','2026-03-31 08:32:06'),('6c564b90-f7f5-4f53-9a99-64d88dc46fe0','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:39:29','2026-03-30 06:39:33'),('6cc9481b-ddd4-45ff-9b0a-1130925e1dcc','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:14:51','2026-03-31 09:14:51'),('6e123ff1-42c8-41a1-ad4d-fb772e6b3637','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:49','2026-03-31 09:17:49'),('6e437ebd-3d9d-445a-aebe-1200f9a39692','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:39:29','2026-03-30 06:39:29'),('6efeea56-cf07-4718-9936-ba615361dd57','22222222-2222-2222-2222-222222222222','Tell me about AI solutions',1,'2026-03-30 05:27:50','2026-03-30 05:27:50'),('7014f03b-bda3-458e-8feb-fb098b15b086','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:06:54','2026-03-31 09:06:54'),('704db2db-ce53-45cc-9650-35a046566ff9','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 08:14:58','2026-03-31 08:14:58'),('705b5f4f-45cc-4004-88c7-a18ebc4aee5e','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:48','2026-03-31 09:17:48'),('70b6cd1b-7152-48d4-bd7c-b59ca77888b4','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:42:14','2026-03-30 06:42:17'),('7118d760-8698-4daf-8008-9802245c57ac','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 05:36:56','2026-03-30 05:36:56'),('717e2d9a-f5ff-4270-a9fa-318431932195','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:08:59','2026-03-31 09:08:59'),('73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-04-02 14:52:11','2026-04-02 16:15:53'),('743631b7-7c35-4d59-ae8c-4b6738d3ec43','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 06:00:28','2026-03-30 06:00:28'),('74b41e3a-9b5a-4530-93e6-119d3a0ff0a4','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:32:33','2026-03-30 08:32:33'),('753a5ab8-161d-4c86-a45a-1e46525b69bb','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:27','2026-03-30 09:13:27'),('754902b4-ab63-4a40-9013-116766fe429f','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:30','2026-03-31 09:09:30'),('76b843f6-520d-462e-ad86-7ebc128b5fc3','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:49','2026-03-31 09:17:49'),('7782093f-10c4-42ef-9a13-69ef3f71fd15','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:00','2026-03-31 09:19:00'),('77b6e590-3480-40ec-a58c-a038b70e7b0e','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:19','2026-03-31 09:19:19'),('7885a84a-0e39-46b2-99e3-860d7d7ab47a','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 13:41:28','2026-03-31 13:41:28'),('7a006154-97b5-4c29-b026-8f4843905ef7','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:07:03','2026-03-30 06:07:03'),('7a50c990-6144-4ceb-bf6b-621fbc47867a','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:33:58','2026-03-30 06:38:29'),('7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 07:12:45','2026-03-30 07:14:01'),('7ae09e63-42af-456e-8cc0-92188152cd67','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:42:08','2026-03-30 06:42:08'),('7c241086-3f6b-4498-9c14-a3b1c5612813','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:11:27','2026-03-31 09:11:27'),('7f3882b5-3eb1-4a8b-8b27-e329b7933d18','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:27:44','2026-03-31 08:27:44'),('7f9bdae4-a9d3-4df6-8555-18f636068d3f','d58d621a-5700-4efa-b864-a1cd528562a9','New Conversation',1,'2026-03-31 09:14:43','2026-03-31 09:14:43'),('83c8919b-3f0a-4ed2-85d9-98773df52961','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:32:46','2026-03-30 06:33:12'),('867722b7-c388-4d20-8b48-978b7afb3138','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:33','2026-03-31 09:09:33'),('869183f5-389d-42cc-83cf-ab28810674d1','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:32:20','2026-03-30 08:32:20'),('8c9bd68d-c91d-4016-8877-6ed7606c217c','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:16:44','2026-03-31 09:16:44'),('8d343f9a-7e4f-40b3-8857-724e900aa28b','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-30 05:36:56','2026-03-30 05:36:56'),('8dedae45-a657-4a9e-a3cd-ef9798a5068b','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:15:17','2026-03-31 09:15:17'),('8e41ee20-c968-417a-ad92-705f15f84f45','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:31:59','2026-03-31 08:31:59'),('8e853e19-31b6-4d25-b301-9d5491fe3df3','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 07:57:19','2026-03-31 07:57:19'),('90822529-a682-41d3-95f5-cdeb1b95f184','22222222-2222-2222-2222-222222222222','Cloud migration help',1,'2026-03-30 05:43:10','2026-03-30 05:43:12'),('923ad694-3056-4632-b9b6-cb72888cdf9d','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:23:17','2026-03-31 09:23:17'),('93c3f626-4c4a-4928-956a-bacd834a9f51','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:13','2026-03-30 09:13:18'),('941a3f49-3229-42f3-bd1e-cfea4c1aa9a0','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 05:43:05','2026-03-30 05:43:05'),('953357d0-7f01-4a18-94a2-602766ec13e4','11111111-1111-1111-1111-111111111111','check balance',1,'2026-03-30 06:00:54','2026-03-30 06:01:05'),('96ddfedf-30cd-4dbd-8973-ba32e23ebb34','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 07:51:34','2026-03-31 07:51:34'),('985a8b3d-2886-41bb-a73c-f3497d77c0ce','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-04-02 14:52:11','2026-04-02 14:52:11'),('9b40a0a5-6eda-454a-a521-cf5b71ec9129','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:41','2026-03-31 09:19:41'),('9d7a12be-78b3-45e2-8551-72ade64442da','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:16:44','2026-03-31 09:16:44'),('9ea3b9de-378c-40d3-affd-cceeda5a458b','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 07:12:45','2026-03-30 07:12:45'),('9ecba1e7-02f1-4656-8ee6-6c9d9695ffa9','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:18','2026-03-31 09:19:18'),('9fb3bb36-5d6a-4081-ae14-4c91b8a4e6c4','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:11:24','2026-03-31 09:11:24'),('9fd43cf2-5f69-408a-b2c5-48653df5803b','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:16','2026-03-31 09:19:16'),('a147fcb2-7e62-4574-a414-7b9b0fa03d0e','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 07:57:19','2026-03-31 07:57:19'),('a1c47c8f-8afa-4c5f-ad6e-de6a8d6c5171','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:23:17','2026-03-31 09:23:17'),('a2532255-852e-4abb-85ba-11e06c06536a','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:43','2026-03-31 09:17:43'),('a54f68e4-232b-4d1d-9c77-cc27dca0d786','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 07:27:53','2026-03-31 07:27:53'),('a7eeb485-033c-4216-bb5b-79e6d4ba1906','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-04-02 14:23:06','2026-04-02 14:23:06'),('aadae08e-e42e-46b7-ae52-bccbb3791627','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 07:51:34','2026-03-31 07:51:34'),('aae4ef49-bab5-4dd7-a234-8d8196abf5ce','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:11:26','2026-03-31 09:11:26'),('aba0319d-fdca-4a87-a5d4-4585ed3b4899','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 13:27:00','2026-03-30 13:27:00'),('ae4596fe-e7fe-45b3-a359-1c85a5c11ce4','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:27:06','2026-03-30 06:27:14'),('ae5d9b5c-6d24-43e6-8c08-6a86ab8f3ff6','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:32:53','2026-03-30 06:32:53'),('af15ed28-f721-4206-a0c9-6aa686f13432','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-04-02 14:22:39','2026-04-02 14:23:03'),('af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:11:21','2026-03-30 06:15:34'),('afc235cd-2981-4684-9cd9-8aaea64146d7','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 13:27:00','2026-03-30 13:27:00'),('b0109cd0-32bf-4a51-a192-35dfc083f418','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:00','2026-03-31 09:19:00'),('b151d58c-fd45-4093-92af-42ad7a5cc064','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:26:57','2026-03-31 08:26:57'),('b15a7c2c-9dcf-413c-bd94-2454b06dba1e','d58d621a-5700-4efa-b864-a1cd528562a9','New Conversation',1,'2026-03-31 07:50:37','2026-03-31 07:50:37'),('b1e76732-e2e5-4672-8f29-674b39569622','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:33:47','2026-03-30 06:33:51'),('b275f245-2b78-4fd1-a4d3-08bfceaa4548','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:06:42','2026-03-31 09:06:42'),('b2d8600a-032d-4539-be01-bdc98b51a3d2','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:27:44','2026-03-31 08:27:44'),('b4f69891-b125-4aae-bdfb-85414278b037','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:42:08','2026-03-30 06:42:12'),('b75ff702-309b-4c1a-95e3-2577a7bd1b55','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:13:17','2026-03-31 09:13:17'),('bb59de56-97dc-4ba4-ad8e-fbcf03262659','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 07:12:22','2026-03-30 07:12:22'),('bc25d4b2-cb04-4d97-97e4-8bc676a23eeb','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 13:42:05','2026-03-31 13:42:05'),('bcb61267-a1f6-4a75-b96a-56eefb42fc6f','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:05:57','2026-03-31 09:05:57'),('be95c1b2-a1e0-4e13-865d-070cb6dbb6f7','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:11:19','2026-03-31 09:11:19'),('c0e04776-0005-404a-8cd2-dded877bde4e','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:19','2026-03-31 09:19:19'),('c2d7bd53-5b58-437d-9f34-4842f3643917','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:05:57','2026-03-31 09:05:57'),('c44f0434-ad94-47af-9a2a-009998af089d','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:12:01','2026-03-31 08:12:01'),('c4cdec44-4e3d-4131-a54e-38b04b0c92a2','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 06:42:14','2026-03-30 06:42:14'),('c4ed190f-f8ad-4d69-a27c-6fbdb19223a6','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:33','2026-03-31 09:09:33'),('cbc97bee-0c4d-46cc-a2df-8368fd3427cf','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:41','2026-03-31 09:19:41'),('cbf1f991-c60a-4a41-a476-204ef0246916','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:10:11','2026-03-31 08:10:11'),('cd817a4a-fb03-4ce3-8648-9d8032479dac','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:06:42','2026-03-31 09:06:42'),('cf4504f2-449f-4cff-94e7-4d9cba254fee','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:17:47','2026-03-31 09:17:47'),('d01897e9-08c2-48ab-8049-611d2c765258','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 07:27:53','2026-03-31 07:27:58'),('d2b3548d-5f61-4036-a35a-fff6d3b9be9b','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:08','2026-03-31 09:09:08'),('d5b80f9b-d2fe-4974-b022-352024f54a23','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:32:06','2026-03-31 08:32:06'),('d787720d-28f5-4494-83da-d32f1e0f6880','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:02:50','2026-03-31 09:02:50'),('d87d9f90-5057-4a36-92c0-1048c2832124','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:17','2026-03-31 09:19:17'),('db171fc3-3c56-4e04-a87c-13ba0ab504c2','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:54','2026-03-30 09:13:54'),('db98655a-fbc9-4af6-bd35-17a131412d1e','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 11:11:05','2026-03-31 11:11:05'),('dc656f9e-5c50-4c3f-b62b-b55d5d98d31e','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:19:18','2026-03-31 09:19:18'),('de60276c-f1a8-4524-9f5a-a7fc36c7f6d8','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 07:46:50','2026-03-31 07:46:54'),('df0af98d-d298-44ec-bea4-affa5f1472be','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:12:24','2026-03-31 09:12:24'),('dfbc7943-0245-451a-af49-d4d40e7e806b','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-30 06:33:47','2026-03-30 06:33:47'),('e1ee9e07-8b1c-47f8-ac6d-81a75c5d7bf7','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 07:12:22','2026-03-30 07:12:26'),('e20803c7-f97e-4c8a-9e18-5b1dbb9ab5f9','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:15:17','2026-03-31 09:15:17'),('e2632f79-1787-4d70-8598-34aab61c4fe6','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 07:26:36','2026-03-31 07:27:02'),('e27fdf6a-83b3-41fa-86ef-4fb433fab668','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:10:11','2026-03-31 08:10:11'),('e86cdfec-4156-4243-927c-a85c8cff8198','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 08:26:57','2026-03-31 08:26:57'),('e9641f36-cf9f-4323-97b9-2e8c7a086a55','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:27','2026-03-30 09:13:31'),('e97f3f95-a356-4571-8337-511472dc3d42','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:08:59','2026-03-31 09:08:59'),('ea8ad8a4-0f74-4c41-b341-defcc3bced81','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-31 11:07:27','2026-03-31 11:07:27'),('eacb8fad-6ed5-485c-a61e-cfb4cc16d83a','22222222-2222-2222-2222-222222222222','Check balance',1,'2026-03-30 06:01:13','2026-03-30 06:01:20'),('eb05d099-d32c-4cd4-9f22-cb56e73e4d6a','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:15:14','2026-03-31 09:15:14'),('ed3547e8-2bbf-4802-b7e4-b4acc7001fbb','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:07:06','2026-03-31 09:07:06'),('ee858d66-0dda-4e2b-a98a-b7893b182fbf','11111111-1111-1111-1111-111111111111','New Conversation',1,'2026-03-31 08:15:38','2026-03-31 08:15:38'),('ef137523-3f18-4841-b185-38d285defaf8','11111111-1111-1111-1111-111111111111','What services does Aditya Bank offer?',1,'2026-03-30 05:27:33','2026-03-30 07:11:27'),('f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:32:33','2026-03-30 08:33:35'),('f31886eb-fcfe-49fe-99b4-6362ccc22693','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 07:52:12','2026-03-31 07:52:12'),('f4df8e66-1714-4131-b7ca-4d58129c2c2d','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:11:24','2026-03-31 09:11:24'),('f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-31 11:07:27','2026-03-31 11:09:29'),('f7d91206-8c72-4248-950f-07b542bb6d83','e922f847-7f66-4d84-9c43-bdc18b28c3d2','New Conversation',1,'2026-03-31 08:10:03','2026-03-31 08:10:03'),('f86bfcdd-5dae-481b-b190-5d01b5c0ff4e','22222222-2222-2222-2222-222222222222','New Conversation',1,'2026-03-31 09:09:50','2026-03-31 09:09:50'),('f8c11fae-a91e-4f95-abc7-924e8fa0cdbc','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:07:06','2026-03-31 09:07:20'),('fa0f24e4-672f-426b-86d7-dc51bca3f3b4','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 08:32:20','2026-03-30 08:32:29'),('fa69c136-7c2e-492c-ae58-807617ef5246','44444444-4444-4444-4444-444444444444','New Conversation',1,'2026-03-31 09:16:53','2026-03-31 09:16:53'),('fae8d9d7-cbe1-44d1-b1c6-d37084e1b64c','33333333-3333-3333-3333-333333333333','New Conversation',1,'2026-03-30 09:13:54','2026-03-30 09:14:05'),('sess-001','22222222-2222-2222-2222-222222222222','Balance & Transactions',1,'2026-03-27 05:26:32','2026-03-27 05:26:32'),('sess-002','33333333-3333-3333-3333-333333333333','Loan Help',1,'2026-03-28 05:26:32','2026-03-28 05:26:32'),('sess-003','55555555-5555-5555-5555-555555555555','Investment Support',1,'2026-03-29 05:26:32','2026-03-29 05:26:32');
/*!40000 ALTER TABLE `chat_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `disputes`
--

DROP TABLE IF EXISTS `disputes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `disputes` (
  `dispute_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_id` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','under_review','resolved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dispute_id`),
  KEY `idx_disputes_user_id` (`user_id`),
  KEY `idx_disputes_transaction_id` (`transaction_id`),
  KEY `idx_disputes_status` (`status`),
  CONSTRAINT `fk_disputes_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_disputes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `disputes`
--

LOCK TABLES `disputes` WRITE;
/*!40000 ALTER TABLE `disputes` DISABLE KEYS */;
INSERT INTO `disputes` VALUES (1,'22222222-2222-2222-2222-222222222222','TXN100001','DSP-1001','Unauthorized debit transaction','under_review','Customer reported unknown e-commerce transaction','2026-03-30 05:26:31'),(2,'33333333-3333-3333-3333-333333333333','TXN100004','DSP-1002','Duplicate rent debit','pending','Needs verification with merchant','2026-03-30 05:26:31'),(3,'22222222-2222-2222-2222-222222222222','TXN100001','DSP-1001','Unauthorized debit transaction','under_review','Customer reported unknown e-commerce transaction','2026-03-30 05:44:39'),(4,'33333333-3333-3333-3333-333333333333','TXN100004','DSP-1002','Duplicate rent debit','pending','Needs verification with merchant','2026-03-30 05:44:39'),(5,'11111111-1111-1111-1111-111111111111',NULL,'DSP20260331YLTROBWT','Transaction dispute','pending',NULL,'2026-03-31 11:12:21');
/*!40000 ALTER TABLE `disputes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exchange_rates`
--

DROP TABLE IF EXISTS `exchange_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exchange_rates` (
  `rate_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `from_currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `to_currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate` decimal(15,6) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rate_id`),
  UNIQUE KEY `uq_exchange_rates_pair` (`from_currency`,`to_currency`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exchange_rates`
--

LOCK TABLES `exchange_rates` WRITE;
/*!40000 ALTER TABLE `exchange_rates` DISABLE KEYS */;
INSERT INTO `exchange_rates` VALUES (1,'USD','INR',83.250000,'2026-03-30 05:26:32'),(2,'EUR','INR',90.100000,'2026-03-30 05:26:32'),(3,'GBP','INR',105.550000,'2026-03-30 05:26:32');
/*!40000 ALTER TABLE `exchange_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `message_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` enum('up','down') COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_text` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_feedback_message_user` (`message_id`,`user_id`),
  KEY `idx_feedback_user` (`user_id`),
  CONSTRAINT `fk_feedback_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES (1,'msg-002','22222222-2222-2222-2222-222222222222','up','Very helpful response','2026-03-27 05:26:33'),(2,'msg-006','33333333-3333-3333-3333-333333333333','up','Loan details were accurate','2026-03-28 05:26:33'),(3,'msg-012','55555555-5555-5555-5555-555555555555','down','Response took a bit longer than expected','2026-03-29 05:26:33');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fixed_deposits`
--

DROP TABLE IF EXISTS `fixed_deposits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fixed_deposits` (
  `fd_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `principal_amount` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL,
  `tenure_months` int NOT NULL,
  `start_date` date NOT NULL,
  `maturity_date` date NOT NULL,
  `maturity_amount` decimal(15,2) NOT NULL,
  `status` enum('active','matured','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`fd_id`),
  KEY `idx_fixed_deposits_user_id` (`user_id`),
  KEY `idx_fixed_deposits_status` (`status`),
  CONSTRAINT `fk_fixed_deposits_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fixed_deposits`
--

LOCK TABLES `fixed_deposits` WRITE;
/*!40000 ALTER TABLE `fixed_deposits` DISABLE KEYS */;
INSERT INTO `fixed_deposits` VALUES (1,'22222222-2222-2222-2222-222222222222',100000.00,7.25,12,'2025-06-01','2026-06-01',107250.00,'active','2026-03-30 05:26:31'),(2,'55555555-5555-5555-5555-555555555555',250000.00,7.80,24,'2025-01-15','2027-01-15',289000.00,'active','2026-03-30 05:26:31'),(3,'22222222-2222-2222-2222-222222222222',100000.00,7.25,12,'2025-06-01','2026-06-01',107250.00,'active','2026-03-30 05:44:39'),(4,'55555555-5555-5555-5555-555555555555',250000.00,7.80,24,'2025-01-15','2027-01-15',289000.00,'active','2026-03-30 05:44:39');
/*!40000 ALTER TABLE `fixed_deposits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `investment_holdings`
--

DROP TABLE IF EXISTS `investment_holdings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `investment_holdings` (
  `holding_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `investment_id` bigint unsigned NOT NULL,
  `quantity` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `avg_buy_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`holding_id`),
  KEY `idx_investment_holdings_user_id` (`user_id`),
  KEY `idx_investment_holdings_investment_id` (`investment_id`),
  CONSTRAINT `fk_investment_holdings_investment` FOREIGN KEY (`investment_id`) REFERENCES `investments` (`investment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_investment_holdings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `investment_holdings`
--

LOCK TABLES `investment_holdings` WRITE;
/*!40000 ALTER TABLE `investment_holdings` DISABLE KEYS */;
INSERT INTO `investment_holdings` VALUES (1,'22222222-2222-2222-2222-222222222222',1,12.0000,3950.00,'2026-03-30 05:26:31'),(2,'55555555-5555-5555-5555-555555555555',2,35.0000,1550.00,'2026-03-30 05:26:31'),(3,'55555555-5555-5555-5555-555555555555',4,8.0000,2700.00,'2026-03-30 05:26:31'),(4,'22222222-2222-2222-2222-222222222222',1,12.0000,3950.00,'2026-03-30 05:44:39'),(5,'55555555-5555-5555-5555-555555555555',2,35.0000,1550.00,'2026-03-30 05:44:39'),(6,'55555555-5555-5555-5555-555555555555',4,8.0000,2700.00,'2026-03-30 05:44:39');
/*!40000 ALTER TABLE `investment_holdings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `investments`
--

DROP TABLE IF EXISTS `investments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `investments` (
  `investment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `symbol` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `current_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `change_percent` decimal(8,2) NOT NULL DEFAULT '0.00',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`investment_id`),
  UNIQUE KEY `symbol` (`symbol`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `investments`
--

LOCK TABLES `investments` WRITE;
/*!40000 ALTER TABLE `investments` DISABLE KEYS */;
INSERT INTO `investments` VALUES (1,'TCS','Tata Consultancy Services',4125.50,1.85,'2026-03-30 05:26:31'),(2,'INFY','Aditya Bank Ltd.',1680.25,-0.42,'2026-03-30 07:10:53'),(3,'HDFCBANK','HDFC Bank Ltd.',1542.00,0.95,'2026-03-30 05:26:31'),(4,'RELIANCE','Reliance Industries',2865.40,2.10,'2026-03-30 05:26:31');
/*!40000 ALTER TABLE `investments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loan_payments`
--

DROP TABLE IF EXISTS `loan_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_payments` (
  `payment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `loan_id` bigint unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `paid_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reference_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `idx_loan_payments_loan_id` (`loan_id`),
  KEY `idx_loan_payments_paid_at` (`paid_at`),
  CONSTRAINT `fk_loan_payments_loan` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`loan_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_loan_payments_amount_positive` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loan_payments`
--

LOCK TABLES `loan_payments` WRITE;
/*!40000 ALTER TABLE `loan_payments` DISABLE KEYS */;
INSERT INTO `loan_payments` VALUES (1,1,25400.00,'2026-02-28 05:26:31','LPAY-1001'),(2,1,25400.00,'2026-01-29 05:26:31','LPAY-1002'),(3,2,18500.00,'2026-03-05 05:26:31','LPAY-1003'),(4,1,25400.00,'2026-02-28 05:44:39','LPAY-1001'),(5,1,25400.00,'2026-01-29 05:44:39','LPAY-1002'),(6,2,18500.00,'2026-03-05 05:44:39','LPAY-1003');
/*!40000 ALTER TABLE `loan_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loans`
--

DROP TABLE IF EXISTS `loans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loans` (
  `loan_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loan_type` enum('personal','home','car','education','business') COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_amount` decimal(15,2) NOT NULL,
  `outstanding_balance` decimal(15,2) NOT NULL,
  `interest_rate` decimal(5,2) NOT NULL,
  `monthly_payment` decimal(15,2) NOT NULL,
  `next_due_date` date DEFAULT NULL,
  `status` enum('active','closed','defaulted','pending') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`loan_id`),
  KEY `idx_loans_user_id` (`user_id`),
  KEY `idx_loans_status` (`status`),
  CONSTRAINT `fk_loans_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loans`
--

LOCK TABLES `loans` WRITE;
/*!40000 ALTER TABLE `loans` DISABLE KEYS */;
INSERT INTO `loans` VALUES (1,'33333333-3333-3333-3333-333333333333','home',2500000.00,1985000.00,8.50,25400.00,'2026-04-09','active','2026-03-30 05:26:31','2026-03-30 05:26:31'),(2,'44444444-4444-4444-4444-444444444444','car',800000.00,245000.00,9.25,18500.00,'2026-04-05','active','2026-03-30 05:26:31','2026-03-30 05:26:31'),(3,'33333333-3333-3333-3333-333333333333','home',2500000.00,1985000.00,8.50,25400.00,'2026-04-09','active','2026-03-30 05:44:39','2026-03-30 05:44:39'),(4,'44444444-4444-4444-4444-444444444444','car',800000.00,245000.00,9.25,18500.00,'2026-04-05','active','2026-03-30 05:44:39','2026-03-30 05:44:39');
/*!40000 ALTER TABLE `loans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sender` enum('user','bot') COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `intent` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confidence` decimal(5,4) DEFAULT NULL,
  `response_time` int DEFAULT NULL,
  `is_flagged` tinyint(1) NOT NULL DEFAULT '0',
  `feedback` enum('positive','negative') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_messages_session_id` (`session_id`),
  KEY `idx_messages_user_id` (`user_id`),
  KEY `idx_messages_created_at` (`created_at`),
  KEY `idx_messages_intent` (`intent`),
  CONSTRAINT `fk_messages_session` FOREIGN KEY (`session_id`) REFERENCES `chat_sessions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES ('0053c283-77f5-4c6b-af15-ad2571bd3f05','af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','bot','Aditya Bank offers a comprehensive range of services: 🚀\n🔷 **IT Services** — Application development & maintenance\n🔷 **Consulting** — Business transformation & strategy\n🔷 **Digital** — UX/UI, e-commerce & digital marketing\n🔷 **Cloud** — Migration, management & optimization\n🔷 **Data & AI** — Analytics, ML and AI solutions\n🔷 **Cybersecurity** — Security ops & compliance\n🔷 **BPM** — Business process management\n🔷 **Engineering** — Product engineering & R&D\nWould you like details on any specific service?','ask_services',0.9992,554,0,NULL,'2026-03-30 06:11:23'),('005ebc26-6997-4478-bb11-97490078a10a','e2632f79-1787-4d70-8598-34aab61c4fe6','11111111-1111-1111-1111-111111111111','bot','🏦 No branches found in \'your area\'. Please try another city or area.','find_branch',0.9615,3439,0,NULL,'2026-03-31 07:26:50'),('01881567-fd36-4a9c-9016-70097a0b2bfd','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','500',NULL,NULL,NULL,0,NULL,'2026-03-31 11:08:12'),('02eb3c0a-40fb-4706-809c-1bf97f607795','51d9b84c-7ed1-47eb-b353-154f23712257','33333333-3333-3333-3333-333333333333','bot','💳 **Your Cards (1 total):**\n🔒 **Mastercard Credit**\n   Number: **** **** **** 4444\n   Expires: 2027-10-31\n   Status: Frozen\n   Credit Limit: ₹100,000.00\n   Available: ₹72,500.00','view_cards',0.9490,2489,0,NULL,'2026-03-30 08:33:54'),('0453764b-6821-473e-a3b5-7212ed50923f','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','Loan rate',NULL,NULL,NULL,0,NULL,'2026-03-30 07:13:24'),('05ff5db3-c16c-4e85-b7ff-a1392eea10f2','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','asdee',NULL,NULL,NULL,0,NULL,'2026-04-02 15:03:16'),('06f81c22-f830-46af-8f04-f1e5feb55f45','83c8919b-3f0a-4ed2-85d9-98773df52961','22222222-2222-2222-2222-222222222222','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,2305,0,NULL,'2026-03-30 06:33:12'),('0a98b989-eecd-4f3b-81fd-243e12e64e70','e2632f79-1787-4d70-8598-34aab61c4fe6','11111111-1111-1111-1111-111111111111','user',']Branches',NULL,NULL,NULL,0,NULL,'2026-03-31 07:26:59'),('0b0079ca-31ed-434d-9a31-854857d076bc','fa0f24e4-672f-426b-86d7-dc51bca3f3b4','33333333-3333-3333-3333-333333333333','bot','Our AI service is temporarily unavailable. Please try again shortly.','fallback',1.0000,2318,0,NULL,'2026-03-30 08:32:29'),('0b849f46-f5e4-48c0-8138-16e2a22dea4d','1f0a9c96-27d8-46fe-94cf-529f402b2188','11111111-1111-1111-1111-111111111111','user','Who is eligible for loan',NULL,NULL,NULL,0,NULL,'2026-04-02 14:23:20'),('0c1f506b-f24b-4f62-9c3e-ea2f4e28b0d4','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','I didn\'t quite understand that. Type \'help\' to see what I can do for you.','nlu_fallback',0.6500,300,0,NULL,'2026-03-30 07:13:58'),('0cfff6cb-8314-49f4-85c1-f94ea457ac5c','fae8d9d7-cbe1-44d1-b1c6-d37084e1b64c','33333333-3333-3333-3333-333333333333','user','Transfer funds',NULL,NULL,NULL,0,NULL,'2026-03-30 09:13:55'),('0d137400-3793-46b5-b6bb-3c0bf5d6fa2c','6efeea56-cf07-4718-9936-ba615361dd57','22222222-2222-2222-2222-222222222222','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,255,0,NULL,'2026-03-30 05:27:50'),('13866b61-f530-434e-8e98-7d524bb9b02f','83c8919b-3f0a-4ed2-85d9-98773df52961','22222222-2222-2222-2222-222222222222','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:33:10'),('13ed6f32-f6e4-446b-b4c1-79b6227eff57','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,531,0,NULL,'2026-03-31 11:08:38'),('15be8e5b-3b5b-45c2-aef8-d345da7084a1','b4f69891-b125-4aae-bdfb-85414278b037','33333333-3333-3333-3333-333333333333','bot','📋 **Transactions** (2 found):\n🔴 Mar 27, 2026 | Zomato | -₹1,200.00 | ID: TXN100003\n🔴 Mar 23, 2026 | Rent Transfer | -₹8,000.00 | ID: TXN100004','view_transactions',0.8078,2825,0,NULL,'2026-03-30 06:42:12'),('161a8112-4e6a-45c6-96c0-f228a0cc7214','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','show contact wew',NULL,NULL,NULL,0,NULL,'2026-04-02 15:39:56'),('16560323-7875-485a-b3e6-af051db3d244','af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','bot','I\'m sorry, I\'m not sure how to help with that. Try asking about our services, tech support, or careers!','nlu_fallback',0.6000,310,0,NULL,'2026-03-30 06:11:31'),('16a01e79-45ba-4e07-adba-6468eabe573a','f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','bot','I\'m sorry, I didn\'t understand that. Could you rephrase?','check_loan_eligibility',0.9490,2431,0,NULL,'2026-03-30 08:33:35'),('16d57af9-92e7-4e0e-8766-626a5ab37e69','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','Give me staff number',NULL,NULL,NULL,0,NULL,'2026-04-02 15:13:10'),('1a551b54-f277-4c03-9f58-4ddad4ced82e','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','user','loans',NULL,NULL,NULL,0,NULL,'2026-03-30 06:44:19'),('1c6edd79-a13e-476f-b1a6-59f9d8aa27aa','1304c366-d1eb-4f19-9438-7978dd611511','11111111-1111-1111-1111-111111111111','user','bank statement',NULL,NULL,NULL,0,NULL,'2026-03-31 11:11:08'),('1d4e7306-36b3-41c1-9009-f35c7d1dd87d','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','user','freeze my card',NULL,NULL,NULL,0,NULL,'2026-03-30 06:43:50'),('1ebb9f5c-dd33-4fae-abdd-6fab6d85a31b','f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','bot','🏦 **Loan Services**\nYou can ask:\n- Check loan balance\n- View loan details\n- EMI / repayment schedule\n- Loan interest rates\n- Loan eligibility\n- Apply for a loan','view_loan_details',0.9385,310,0,NULL,'2026-03-30 08:33:21'),('22d8fadd-280f-4858-af3b-7c0058538a75','f8c11fae-a91e-4f95-abc7-924e8fa0cdbc','44444444-4444-4444-4444-444444444444','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-31 09:07:16'),('23267f77-dc58-4861-942b-684f7fd531f7','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Could you rephrase or type \'help\'?','nlu_fallback',0.6500,305,0,NULL,'2026-03-30 06:44:08'),('23a12add-e1b5-4a7a-80ae-b1004e3cada5','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,461,0,NULL,'2026-04-02 14:53:37'),('24669c14-a180-422b-aff3-3cb66f191720','70b6cd1b-7152-48d4-bd7c-b59ca77888b4','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:42:15'),('26740ac3-f96d-44d9-a1c3-96b73d3138bd','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','help',NULL,NULL,NULL,0,NULL,'2026-03-31 11:08:23'),('2698a7b9-1b2e-44f6-90dc-d0110cd0f6f2','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','Please provide a valid transfer amount.','transfer_money',0.9286,2599,0,NULL,'2026-03-31 11:08:07'),('273f898a-1fee-4261-b8fe-748960e60723','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,1018,0,NULL,'2026-04-02 15:46:13'),('28d4be7f-a5fb-4a97-8679-d8302346be1f','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','show contact wew',NULL,NULL,NULL,0,NULL,'2026-04-02 16:15:52'),('292040ae-c43d-4f86-a0ab-48749e823df9','af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:15:34'),('293c0957-6c30-4fce-afc6-4bdcb343d6e4','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,938,0,NULL,'2026-04-02 16:15:53'),('2d4ca27a-33bb-4ea5-b343-7a5334579992','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','loan',NULL,NULL,NULL,0,NULL,'2026-03-31 11:09:10'),('3083f808-8247-4285-809b-e292bb7b543b','90822529-a682-41d3-95f5-cdeb1b95f184','22222222-2222-2222-2222-222222222222','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,277,0,NULL,'2026-03-30 05:43:12'),('308fec97-dfc7-4b39-8795-533a7b5f5b32','e2632f79-1787-4d70-8598-34aab61c4fe6','11111111-1111-1111-1111-111111111111','user','nearwst branch',NULL,NULL,NULL,0,NULL,'2026-03-31 07:26:46'),('30aef3f9-57bb-47b0-91ce-a7e71577c8d4','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','user','list my accounts',NULL,NULL,NULL,0,NULL,'2026-03-31 11:12:01'),('31e1e3c0-2b39-4d4a-be12-51e4832db984','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','user','gftdfcg',NULL,NULL,NULL,0,NULL,'2026-03-30 06:43:27'),('34721b65-900b-49d1-b111-068b853e22ce','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','card',NULL,NULL,NULL,0,NULL,'2026-03-30 07:12:54'),('3697e27f-f6b2-4604-bd2b-3b88766c97a7','7a50c990-6144-4ceb-bf6b-621fbc47867a','33333333-3333-3333-3333-333333333333','bot','⚠️ Session error — please log in again.','check_balance',0.8321,2347,0,NULL,'2026-03-30 06:34:02'),('37096674-4279-476a-a62e-bb62556575e4','1e45845f-b595-46cf-9bf2-b4883d057ef9','11111111-1111-1111-1111-111111111111','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,270,0,NULL,'2026-03-30 06:00:41'),('3a05d9aa-c1f3-4f8e-b511-49baba1396ac','f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','user','Loan eligibility',NULL,NULL,NULL,0,NULL,'2026-03-30 08:33:33'),('3a1541d6-1f11-416e-9f14-9cf0642cbea8','eacb8fad-6ed5-485c-a61e-cfb4cc16d83a','22222222-2222-2222-2222-222222222222','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:01:20'),('3b2c4f7e-a13c-479e-8837-d3fdb27623b8','90822529-a682-41d3-95f5-cdeb1b95f184','22222222-2222-2222-2222-222222222222','user','Cloud migration help',NULL,NULL,NULL,0,NULL,'2026-03-30 05:43:12'),('3baab847-08b1-4b4b-8375-94b44e36a04c','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','Investment',NULL,NULL,NULL,0,NULL,'2026-03-30 07:13:43'),('3ce9590a-2aea-4c36-957a-870189f82d74','d01897e9-08c2-48ab-8049-611d2c765258','11111111-1111-1111-1111-111111111111','user','ATM near me',NULL,NULL,NULL,0,NULL,'2026-03-31 07:27:55'),('3f1bd560-76a2-4d59-9ed5-124fd69fd636','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','bot','I can only help with Aditya Bank banking services. Try asking about accounts, cards, loans, or branches.','out_of_scope',0.9122,511,0,NULL,'2026-03-31 11:11:42'),('40931df8-b2fb-4f99-aaab-4d98d9812e13','f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','user','View loan details',NULL,NULL,NULL,0,NULL,'2026-03-30 08:33:21'),('41389223-dd56-4027-b55b-70cbbe647df5','1e45845f-b595-46cf-9bf2-b4883d057ef9','11111111-1111-1111-1111-111111111111','user','How do I reset my password?',NULL,NULL,NULL,0,NULL,'2026-03-30 06:00:41'),('421ae637-da95-4f90-9124-af8f5ba117cb','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','freeze card',NULL,NULL,NULL,0,NULL,'2026-03-31 11:08:37'),('4482694b-e1b5-4e6b-91ae-157ddfa7e9ab','fae8d9d7-cbe1-44d1-b1c6-d37084e1b64c','33333333-3333-3333-3333-333333333333','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.6500,309,0,NULL,'2026-03-30 09:14:05'),('485dc23d-7922-4617-9d0d-b11bb542462d','1304c366-d1eb-4f19-9438-7978dd611511','11111111-1111-1111-1111-111111111111','bot','📄 **Statement Request Submitted**\nPeriod: Last 30 days\nReference: STMT20260331FKF52JX1\nYour account statement will be available shortly in the secure portal.','download_statement',0.9264,2616,0,NULL,'2026-03-31 11:11:11'),('49b34c0c-293b-41fc-b2da-6d593388c813','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','asdee',NULL,NULL,NULL,0,NULL,'2026-04-02 14:53:36'),('4b077155-81b3-42a2-a621-a81e514e77dc','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','Pune',NULL,NULL,NULL,0,NULL,'2026-03-30 07:13:57'),('4b098f10-b0b7-43e9-a353-a378d3654d9c','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','Transfer money',NULL,NULL,NULL,0,NULL,'2026-03-31 11:08:04'),('50ba70e0-dc1c-43fd-aa24-eef89bb0a2aa','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','💳 **Your Cards (1 total):**\n🔒 **Mastercard Credit**\n   Number: **** **** **** 4444\n   Expires: 2027-10-31\n   Status: Frozen\n   Credit Limit: ₹100,000.00\n   Available: ₹72,500.00','view_cards',0.9721,2646,0,NULL,'2026-03-31 11:08:52'),('52607db8-616e-466d-9f83-c610bb7eefd3','af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','user','What services does Aditya Bank offer?',NULL,NULL,NULL,0,NULL,'2026-03-30 06:11:23'),('52f67f73-10b3-4aa8-87a6-616f6651ea09','de60276c-f1a8-4524-9f5a-a7fc36c7f6d8','11111111-1111-1111-1111-111111111111','bot','No active accounts found on your profile.','check_balance',0.9244,2646,0,NULL,'2026-03-31 07:46:54'),('531f197a-97d6-459a-94af-58d17623bad1','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','Give me staff number',NULL,NULL,NULL,0,NULL,'2026-04-02 15:22:59'),('540e3d1c-7d8c-4030-9438-ae115217aa07','1f0a9c96-27d8-46fe-94cf-529f402b2188','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,524,0,NULL,'2026-04-02 14:23:21'),('54a3a571-48ea-4bc1-9973-0acc55a5fec6','6c564b90-f7f5-4f53-9a99-64d88dc46fe0','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:39:30'),('54ace2b0-9617-41f6-8774-444b177eca4b','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,909,0,NULL,'2026-04-02 16:10:59'),('561755e9-afcc-4c34-aed5-4ed6f3334aae','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','bot','⚠️ **Dispute Raised Successfully**\nTransaction ID: Not provided\nReason: Transaction dispute\nReference: **DSP20260331YLTROBWT**\nOur team will review it and update you soon.','dispute_transaction',0.9197,2638,0,NULL,'2026-03-31 11:12:21'),('5974e0fb-bd14-4165-8e4a-265e19e2f45c','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,578,0,NULL,'2026-04-02 15:13:11'),('5d32ab62-75ef-42be-a21a-f32c132dd5a3','eacb8fad-6ed5-485c-a61e-cfb4cc16d83a','22222222-2222-2222-2222-222222222222','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,291,0,NULL,'2026-03-30 06:01:20'),('5fd867b6-4b15-4b62-9c94-41b119495a70','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','user','fixed deposit',NULL,NULL,NULL,0,NULL,'2026-03-30 06:44:08'),('61b45a77-bdf0-4d13-8b48-4a082459d66a','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,507,0,NULL,'2026-04-02 15:06:12'),('6416306d-720a-4e7a-ba53-aab406c97cda','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Could you rephrase or type \'help\'?','nlu_fallback',0.6500,333,0,NULL,'2026-03-30 06:44:20'),('6a7bcc2c-7b2b-48cd-b876-b82157831069','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','account information',NULL,NULL,NULL,0,NULL,'2026-03-31 11:07:49'),('6ce6985a-4fb1-4277-8e3b-e8a6ae8a745a','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','🔒 **Card Frozen**\nCard: Mastercard **** **** **** 4444\nStatus: Frozen\nNo transactions will be processed. You can unfreeze it anytime.','freeze_card',0.8879,2437,0,NULL,'2026-03-30 07:13:04'),('70361494-d55a-4be2-8eb2-9bcc17483c7b','af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:11:30'),('719ba24d-ce6f-4088-9a6e-84c9533d692f','de60276c-f1a8-4524-9f5a-a7fc36c7f6d8','11111111-1111-1111-1111-111111111111','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-31 07:46:51'),('744757cd-7c52-41bb-9b89-933e523333f7','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','bot','No upcoming bills found.','view_bills',0.7978,2664,0,NULL,'2026-03-31 11:13:03'),('75345514-4183-44d2-836f-6fa5129d5a9f','1a97a05e-b021-4afb-9da1-5a0ff830e68a','33333333-3333-3333-3333-333333333333','bot','I can help you with:\n- 💰 Balance & account details\n- 📋 Transactions & statements\n- 💳 Cards (freeze/unfreeze/report)\n- 🏦 Loans & EMI\n- 📈 Investments\n- 📂 Fixed Deposits\n- 💸 Transfers & bill payments\n- 🏧 Find branch or ATM\n- 🔔 Alerts & notifications','help',0.9515,303,0,NULL,'2026-03-30 09:13:38'),('76b87d4c-8268-40df-af8c-6c994c2b64e2','6c564b90-f7f5-4f53-9a99-64d88dc46fe0','33333333-3333-3333-3333-333333333333','bot','Our AI service is temporarily unavailable. Please try again shortly.','fallback',1.0000,2284,0,NULL,'2026-03-30 06:39:33'),('76d282ba-1127-4b8d-a753-655b64e6ef04','19abee0e-4f84-4757-9f64-b204eba7a878','33333333-3333-3333-3333-333333333333','user','Transactions',NULL,NULL,NULL,0,NULL,'2026-03-30 09:13:45'),('77045349-5266-4c5a-9391-d802c7df5465','af15ed28-f721-4206-a0c9-6aa686f13432','11111111-1111-1111-1111-111111111111','user','Who is eligible for loan',NULL,NULL,NULL,0,NULL,'2026-04-02 14:23:01'),('78406493-4ca0-40b0-a700-6bbcb5a5274c','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','I didn\'t quite understand that. Type \'help\' to see what I can do for you.','affirm',0.8721,303,0,NULL,'2026-03-30 07:14:01'),('790af9d0-ee60-4e0f-b096-00f2fe5547f5','d01897e9-08c2-48ab-8049-611d2c765258','11111111-1111-1111-1111-111111111111','bot','🏧 No operational ATMs found in \'your area\'.','find_atm',0.8651,2628,0,NULL,'2026-03-31 07:27:58'),('7b36241a-ca69-4004-8a21-bb3acbda0da9','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','Our AI service is temporarily unavailable. Please try again shortly.','fallback',1.0000,2321,0,NULL,'2026-04-02 15:02:49'),('7eb12091-28f2-443b-acd1-6d6979ce5b5f','ae4596fe-e7fe-45b3-a359-1c85a5c11ce4','22222222-2222-2222-2222-222222222222','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,2314,0,NULL,'2026-03-30 06:27:14'),('7fd9f7d1-1d1b-444f-89da-c0a4d84704b0','93c3f626-4c4a-4928-956a-bacd834a9f51','33333333-3333-3333-3333-333333333333','bot','💱 **Live Exchange Rates (Base: USD)**\n1 USD = 83.2500 INR\n_Updated: 2026-03-30 10:56:32_','view_exchange_rates',0.9341,2445,0,NULL,'2026-03-30 09:13:18'),('815c00c6-c890-4979-9ff9-ac97d9951b0e','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','🏦 No branches found in \'your area\'. Please try another city or area.','find_branch',0.9457,2390,0,NULL,'2026-03-30 07:13:52'),('81e62f62-7b34-44d8-b66c-6cbe322a14e0','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,578,0,NULL,'2026-04-02 15:19:03'),('8325952f-f0e7-49e8-901a-bf83036b7113','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','🏦 **Loan Services**\nYou can ask:\n- Check loan balance\n- View loan details\n- EMI / repayment schedule\n- Loan interest rates\n- Loan eligibility\n- Apply for a loan','view_loan_details',0.9571,520,0,NULL,'2026-03-31 11:09:10'),('834765ac-4cdc-41d8-be64-fcdc050e1ea6','f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','bot','🏦 **Loan Services**\nYou can ask:\n- Check loan balance\n- View loan details\n- EMI / repayment schedule\n- Loan interest rates\n- Loan eligibility\n- Apply for a loan','view_loan_details',0.9666,717,0,NULL,'2026-03-30 08:33:07'),('85471663-d05c-4a87-babd-bbcdb2049823','e1ee9e07-8b1c-47f8-ac6d-81a75c5d7bf7','33333333-3333-3333-3333-333333333333','bot','Our AI service is temporarily unavailable. Please try again shortly.','fallback',1.0000,2338,0,NULL,'2026-03-30 07:12:26'),('895d5dd8-2c91-4d42-b0e7-bae5aeb7bb96','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','user','help',NULL,NULL,NULL,0,NULL,'2026-03-30 06:43:36'),('89a2225a-df68-4307-936b-3bfa3ad1c206','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','Give me staff number',NULL,NULL,NULL,0,NULL,'2026-04-02 15:06:11'),('8c7a2759-18fa-4dd8-89d0-d520a20c2e03','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,544,0,NULL,'2026-03-31 11:08:13'),('8ce9245b-1e3f-423b-854c-e4461280bddc','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Could you rephrase or type \'help\'?','nlu_fallback',0.6500,298,0,NULL,'2026-03-30 06:43:28'),('8cfca2e4-e23b-4564-999c-0bb81b989ab5','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','Give me staff number',NULL,NULL,NULL,0,NULL,'2026-04-02 15:19:02'),('8d42a31e-f6bf-4e72-807f-ce5a92b85cdd','6efeea56-cf07-4718-9936-ba615361dd57','22222222-2222-2222-2222-222222222222','user','Tell me about AI solutions',NULL,NULL,NULL,0,NULL,'2026-03-30 05:27:50'),('8e02d050-64d9-4c4b-9803-26a98555c0db','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','💰 **Salary Account**\nAccount: ****0002\nBalance: ₹45,200.00\nStatus: Active','check_balance',0.9244,3492,0,NULL,'2026-03-31 11:07:34'),('93e38231-1fd7-469d-812e-4e24f3a2fe30','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','show contact wew',NULL,NULL,NULL,0,NULL,'2026-04-02 15:46:12'),('94967dd9-6645-4a7c-a069-a9fdcf286f83','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','I can help you with:\n- 💰 Balance & account details\n- 📋 Transactions & statements\n- 💳 Cards (freeze/unfreeze/report)\n- 🏦 Loans & EMI\n- 📈 Investments\n- 📂 Fixed Deposits\n- 💸 Transfers & bill payments\n- 🏧 Find branch or ATM\n- 🔔 Alerts & notifications','help',0.9270,525,0,NULL,'2026-03-31 11:08:24'),('94a44dea-306b-43a2-a241-c45a18c45211','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','I\'m sorry, I didn\'t understand that. Could you rephrase?','view_loan_interest_rate',0.8108,2693,0,NULL,'2026-03-31 11:09:29'),('94e44e48-0b94-495c-adb0-c31fed61def6','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','freeze card',NULL,NULL,NULL,0,NULL,'2026-03-30 07:13:02'),('9a364583-8285-49bc-972c-3bea66d0294a','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I\'m having trouble connecting to the AI engine. Your message has been logged.','fallback',1.0000,12293,0,NULL,'2026-04-02 15:40:09'),('9aa4e6ef-c551-4864-9541-85770585fd75','953357d0-7f01-4a18-94a2-602766ec13e4','11111111-1111-1111-1111-111111111111','bot','Our AI service is temporarily unavailable. Please try again shortly.','fallback',1.0000,280,0,NULL,'2026-03-30 06:01:05'),('9b9d4859-38f6-4c48-b24a-e132783a5e29','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','Loan interest rates',NULL,NULL,NULL,0,NULL,'2026-03-31 11:09:26'),('9d10d867-5e9c-4372-bebf-b2306eaf340f','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','bot','👤 **Account Holder:** Priya Mehta\n📧 Email: priya@example.com\n📱 Phone: 9876543211\n🏦 **Accounts:**\n• **Salary** — Acct: ****0002 | Balance: ₹45,200.00 | Status: Active','view_account_details',0.9224,2638,0,NULL,'2026-03-31 11:07:52'),('a3c1086c-043c-489a-b97d-8194bd9d8838','fae8d9d7-cbe1-44d1-b1c6-d37084e1b64c','33333333-3333-3333-3333-333333333333','user','500',NULL,NULL,NULL,0,NULL,'2026-03-30 09:14:05'),('a5140df1-ce47-42c1-b1f7-0dbd5b6f9e47','e9641f36-cf9f-4323-97b9-2e8c7a086a55','33333333-3333-3333-3333-333333333333','bot','🏧 No operational ATMs found in \'your area\'.','find_atm',0.9290,2392,0,NULL,'2026-03-30 09:13:31'),('a55cd87d-c43b-4668-818f-aca167885f01','b1e76732-e2e5-4672-8f29-674b39569622','22222222-2222-2222-2222-222222222222','bot','⚠️ Session error — please log in again.','check_balance',0.8321,2988,0,NULL,'2026-03-30 06:33:51'),('a7ece3eb-e9f0-4d0c-9143-696ec9a4c791','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','💰 **Salary Account**\nAccount: ****0002\nBalance: ₹45,200.00\nStatus: Active','check_balance',0.8970,2882,0,NULL,'2026-03-30 07:12:48'),('a82e9e72-145f-4acc-81c3-4b9035fcf0ce','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','I didn\'t quite understand that. Type \'help\' to see what I can do for you.','nlu_fallback',0.6500,287,0,NULL,'2026-03-30 07:13:24'),('a903dc25-2b3f-4da2-beb6-c3877c37700e','f8c11fae-a91e-4f95-abc7-924e8fa0cdbc','44444444-4444-4444-4444-444444444444','bot','💰 **Current Account**\nAccount: ****0003\nBalance: ₹128,900.50\nStatus: Active','check_balance',0.9244,3628,0,NULL,'2026-03-31 09:07:20'),('a96f747a-6fcb-46cc-aab1-6a54cc378701','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','asdee',NULL,NULL,NULL,0,NULL,'2026-04-02 15:02:47'),('a9bf7d63-0a16-4180-bd49-bd16f995d220','ef137523-3f18-4841-b185-38d285defaf8','11111111-1111-1111-1111-111111111111','bot','Our AI service is temporarily unavailable. Please try again shortly.','fallback',1.0000,319,0,NULL,'2026-03-30 05:27:33'),('ac9c0165-3dff-4b91-b5a5-9278339c9c89','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-31 11:07:30'),('adeff73e-e362-4eab-8f1a-6410575f7d6b','e2632f79-1787-4d70-8598-34aab61c4fe6','11111111-1111-1111-1111-111111111111','bot','🏦 No branches found in \'your area\'. Please try another city or area.','find_branch',0.9188,2637,0,NULL,'2026-03-31 07:27:02'),('af90dcff-89a3-4a14-8361-2cc93a57f583','5191c1b5-98b1-485a-b905-5a04932a7f04','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,1196,0,NULL,'2026-03-31 13:41:39'),('afe726b7-4412-4887-8f23-62278d94eed3','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 07:12:46'),('b1cfa597-6c5f-4a05-868b-15e0f271cce5','e9641f36-cf9f-4323-97b9-2e8c7a086a55','33333333-3333-3333-3333-333333333333','user','Find ATM',NULL,NULL,NULL,0,NULL,'2026-03-30 09:13:29'),('b2b792a4-01b3-41a3-8033-79b3d36669ff','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','user','unauthorized charge',NULL,NULL,NULL,0,NULL,'2026-03-31 11:12:18'),('b60c9bba-48ee-4470-91a5-926d5403382a','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','loan eligibility',NULL,NULL,NULL,0,NULL,'2026-04-02 14:52:14'),('b6442fad-6780-4f57-9ef8-ab811b13e1a6','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','user','lock my card',NULL,NULL,NULL,0,NULL,'2026-03-31 11:13:19'),('b76e4c76-f69e-4a34-82fa-2b480f405988','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','I didn\'t quite understand that. Type \'help\' to see what I can do for you.','nlu_fallback',0.6500,303,0,NULL,'2026-03-30 07:13:44'),('b7d579ae-4bcc-426a-b2e5-69fbead64bed','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','bot','I can help you with:\n🏦 Banking\n- Check balance\n- View transactions\n- Transfer money\n- Pay bills\n- Manage cards\nTry asking:\n- \"Check my balance\"\n- \"Show recent transactions\"\n- \"Transfer 500 to John\"\n- \"Pay electricity bill\"\n- \"Freeze my card\"','help',0.9059,309,0,NULL,'2026-03-30 06:43:37'),('ba7b19ef-7dc3-4290-a18b-04e80f448d76','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,995,0,NULL,'2026-04-02 15:03:17'),('baf3135b-f738-4888-91eb-291ef30d537a','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','user','show my bills',NULL,NULL,NULL,0,NULL,'2026-03-31 11:13:00'),('bce885dc-6ba4-4eb8-a7dc-a2f3e8edd1c8','af15ed28-f721-4206-a0c9-6aa686f13432','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,1271,0,NULL,'2026-04-02 14:23:03'),('bddcfc3d-090f-4f85-bed8-e0ad056cfe83','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','Please provide a valid loan amount.','apply_for_loan',0.8072,2397,0,NULL,'2026-03-30 07:13:15'),('bfee989c-baa2-4f34-adea-1d135aabc937','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','Give me staff number',NULL,NULL,NULL,0,NULL,'2026-04-02 15:39:02'),('c0e5a41e-a7ff-47f2-9111-c210f3bd0f9a','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,1045,0,NULL,'2026-04-02 15:33:23'),('c1d4912e-3195-495b-859f-823f42dca3f0','5191c1b5-98b1-485a-b905-5a04932a7f04','11111111-1111-1111-1111-111111111111','user','who is eligible for loan',NULL,NULL,NULL,0,NULL,'2026-03-31 13:41:37'),('c257da65-f0b4-4423-b2af-fcbc7125c8ce','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,821,0,NULL,'2026-04-02 15:01:10'),('c47a3dc8-cdaf-443c-b6d1-2f409398225c','f5d03d9e-921c-4145-af8e-6ce60738034a','33333333-3333-3333-3333-333333333333','user','card',NULL,NULL,NULL,0,NULL,'2026-03-31 11:08:49'),('c7b16f6a-44ed-495a-8913-f904f714481a','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','✅ **Loan Eligibility**\nTo apply for a loan, you generally need:\n- Age must be 18+\n- PAN card\n- Valid ID proof\n- Income proof\n- Good repayment history\n\'','check_loan_eligibility',0.9696,894,0,NULL,'2026-04-02 14:52:15'),('c85d9f82-8991-4a26-8003-9f36b44aae83','7a50c990-6144-4ceb-bf6b-621fbc47867a','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:34:00'),('c8877404-6dd2-4954-a325-fada94e38d7b','19abee0e-4f84-4757-9f64-b204eba7a878','33333333-3333-3333-3333-333333333333','bot','📋 **Transactions** (2 found):\n🔴 Mar 27, 2026 | Zomato | -₹1,200.00 | ID: TXN100003\n🔴 Mar 23, 2026 | Rent Transfer | -₹8,000.00 | ID: TXN100004','view_transactions',0.9817,2432,0,NULL,'2026-03-30 09:13:48'),('ccbf4f24-75c9-41ca-addc-bc82b23b022f','e1ee9e07-8b1c-47f8-ac6d-81a75c5d7bf7','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 07:12:23'),('cd4b412b-5542-4a74-8d5c-c07562123a2a','b1e76732-e2e5-4672-8f29-674b39569622','22222222-2222-2222-2222-222222222222','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:33:48'),('ce693e4d-dc3c-4ad1-8cf7-a4b59e7a9e7c','70b6cd1b-7152-48d4-bd7c-b59ca77888b4','33333333-3333-3333-3333-333333333333','bot','💰 **Salary Account**\nAccount: ****0002\nBalance: ₹45,200.00\nStatus: Active','check_balance',0.8321,2436,0,NULL,'2026-03-30 06:42:17'),('d05a6bb1-35a3-4df6-865f-9ceefa247252','ef137523-3f18-4841-b185-38d285defaf8','11111111-1111-1111-1111-111111111111','user','What services does Aditya Bank offer?',NULL,NULL,NULL,0,NULL,'2026-03-30 05:27:33'),('d0eaff0f-10d4-4e37-b053-b6d9523ccc22','fa0f24e4-672f-426b-86d7-dc51bca3f3b4','33333333-3333-3333-3333-333333333333','user','Loan details',NULL,NULL,NULL,0,NULL,'2026-03-30 08:32:26'),('d1abd4cc-12b0-4816-8e90-b36f55655cc0','ae4596fe-e7fe-45b3-a359-1c85a5c11ce4','22222222-2222-2222-2222-222222222222','user','Help',NULL,NULL,NULL,0,NULL,'2026-03-30 06:27:12'),('d755fad9-a15f-4be3-adc2-f8a51ac442bf','7a50c990-6144-4ceb-bf6b-621fbc47867a','33333333-3333-3333-3333-333333333333','bot','⚠️ Session error — please log in again.','check_balance',0.8321,2383,0,NULL,'2026-03-30 06:38:29'),('d9137a54-e76d-4dc3-a91a-47476379d9ac','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','Give me staff number',NULL,NULL,NULL,0,NULL,'2026-04-02 15:33:22'),('da84b885-0abb-413b-a4f4-a5e61357cbb3','953357d0-7f01-4a18-94a2-602766ec13e4','11111111-1111-1111-1111-111111111111','user','check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:01:05'),('dd108e8d-7cc8-4266-9a71-b8ebc2af97b7','af9f8721-fb57-4c07-9bac-1898b3a38c11','22222222-2222-2222-2222-222222222222','bot','I\'m sorry, I\'m not sure how to help with that. Try asking about our services, tech support, or careers!','nlu_fallback',0.6000,290,0,NULL,'2026-03-30 06:15:34'),('def0e759-0518-4a33-8c12-a965589e8ce0','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','I didn’t quite understand that. Type **help** to see what I can do for you.','nlu_fallback',0.7500,918,0,NULL,'2026-04-02 15:23:00'),('e093013b-da58-4598-b443-da6c74fb01b8','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','near branches',NULL,NULL,NULL,0,NULL,'2026-03-30 07:13:49'),('e193fdf1-f4fb-471b-b27f-3fc184cf59d3','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','bot','Staff Name:ASd\nContact no.: +1234345','staffinfo',0.9599,974,0,NULL,'2026-04-02 15:39:03'),('e569d479-0f85-466c-aab5-e47f82118ce6','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','bot','I didn\'t quite understand that. Type \'help\' to see what I can do for you.','nlu_fallback',0.6500,301,0,NULL,'2026-03-30 07:12:54'),('e6286c15-2c2a-4b4c-a741-3e333cb2956d','7a50c990-6144-4ceb-bf6b-621fbc47867a','33333333-3333-3333-3333-333333333333','user','Check balance',NULL,NULL,NULL,0,NULL,'2026-03-30 06:38:26'),('e720cf30-d5bc-4b2a-a03b-538c9d7539b3','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','user','tell me a joke',NULL,NULL,NULL,0,NULL,'2026-03-31 11:11:41'),('e83a74f1-e04a-4fbf-9249-0aaa89fa6469','93c3f626-4c4a-4928-956a-bacd834a9f51','33333333-3333-3333-3333-333333333333','user','Exchange rates',NULL,NULL,NULL,0,NULL,'2026-03-30 09:13:15'),('e9567bb3-9ba6-4518-8286-5d387c290e7f','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','bot','No accounts found on your profile.','view_all_accounts',0.8756,2600,0,NULL,'2026-03-31 11:12:04'),('eb69616b-bd78-4861-b54e-5b5628312c3a','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','loans',NULL,NULL,NULL,0,NULL,'2026-03-30 07:13:12'),('eb8ea0d6-6c08-4c44-b70c-7c242b796967','b4f69891-b125-4aae-bdfb-85414278b037','33333333-3333-3333-3333-333333333333','user','Transactions',NULL,NULL,NULL,0,NULL,'2026-03-30 06:42:09'),('ebc62cdc-69ed-4aa8-951e-e1ac427e6363','1a97a05e-b021-4afb-9da1-5a0ff830e68a','33333333-3333-3333-3333-333333333333','user','Help',NULL,NULL,NULL,0,NULL,'2026-03-30 09:13:38'),('ec5be279-a5b5-4b36-874c-d751c4676fc9','51d9b84c-7ed1-47eb-b353-154f23712257','33333333-3333-3333-3333-333333333333','user','My cards',NULL,NULL,NULL,0,NULL,'2026-03-30 08:33:52'),('eefbe8a0-8bba-4464-ae2d-478f5cd5aeae','fae8d9d7-cbe1-44d1-b1c6-d37084e1b64c','33333333-3333-3333-3333-333333333333','bot','Please provide a valid transfer amount.','transfer_money',0.9552,2380,0,NULL,'2026-03-30 09:13:58'),('ef18e414-4a4d-4b5a-b3b8-b2a4e5653489','67b2355e-050f-40f4-9475-8959752f8cc8','11111111-1111-1111-1111-111111111111','bot','No active card found. Your card may already be frozen.','freeze_card',0.9045,2435,0,NULL,'2026-03-30 06:43:53'),('f0a7ed2e-7e61-42cc-a773-197b2aef3efa','f2a28892-7fd1-47fb-8a15-b46b2c891532','33333333-3333-3333-3333-333333333333','user','Loan details',NULL,NULL,NULL,0,NULL,'2026-03-30 08:33:06'),('f5c7f148-4339-4688-8bb8-5b0787d3304f','3825dd83-dc91-483e-945f-aec48e327be7','11111111-1111-1111-1111-111111111111','bot','No active card found. Your card may already be frozen.','freeze_card',0.8029,2599,0,NULL,'2026-03-31 11:13:22'),('fa6dbe56-67af-4aba-b5e5-ce712c3b9ce0','7aadd115-8432-4a48-b9df-db25bc9dba47','33333333-3333-3333-3333-333333333333','user','solapur',NULL,NULL,NULL,0,NULL,'2026-03-30 07:14:01'),('fbdee840-df54-4087-ac64-da6c44668252','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','show contact wew',NULL,NULL,NULL,0,NULL,'2026-04-02 16:10:58'),('ff4da5c7-2e14-4c67-9ed0-c193471b5e49','73975788-e165-41a3-bd7c-5c4e4c6ee8b8','11111111-1111-1111-1111-111111111111','user','asdee',NULL,NULL,NULL,0,NULL,'2026-04-02 15:01:09'),('msg-001','sess-001','22222222-2222-2222-2222-222222222222','user','Check my account balance','check_balance',0.9812,1200,0,'positive','2026-03-27 05:26:32'),('msg-002','sess-001','22222222-2222-2222-2222-222222222222','bot','Your current account balance is ?85,250.75',NULL,NULL,900,0,'positive','2026-03-27 05:26:32'),('msg-003','sess-001','22222222-2222-2222-2222-222222222222','user','Show my recent transactions','recent_transactions',0.9540,1450,0,'positive','2026-03-27 05:26:32'),('msg-004','sess-001','22222222-2222-2222-2222-222222222222','bot','Here are your last 5 transactions.',NULL,NULL,980,0,'positive','2026-03-27 05:26:32'),('msg-005','sess-002','33333333-3333-3333-3333-333333333333','user','What is my loan EMI?','loan_emi',0.9650,1100,0,'positive','2026-03-28 05:26:32'),('msg-006','sess-002','33333333-3333-3333-3333-333333333333','bot','Your monthly EMI is ?25,400.',NULL,NULL,870,0,'positive','2026-03-28 05:26:32'),('msg-007','sess-002','33333333-3333-3333-3333-333333333333','user','When is my next loan due date?','loan_due_date',0.9410,1020,0,'positive','2026-03-28 05:26:32'),('msg-008','sess-002','33333333-3333-3333-3333-333333333333','bot','Your next loan payment is due in 10 days.',NULL,NULL,910,0,'positive','2026-03-28 05:26:32'),('msg-009','sess-003','55555555-5555-5555-5555-555555555555','user','Show my investments','investment_portfolio',0.9770,1320,0,'positive','2026-03-29 05:26:32'),('msg-010','sess-003','55555555-5555-5555-5555-555555555555','bot','You currently hold Aditya Bank and Reliance shares.',NULL,NULL,990,0,'positive','2026-03-29 05:26:32'),('msg-011','sess-003','55555555-5555-5555-5555-555555555555','user','What is the current stock price of Aditya Bank?','stock_price',0.9235,1540,0,'negative','2026-03-29 05:26:32'),('msg-012','sess-003','55555555-5555-5555-5555-555555555555','bot','Aditya Bank is currently trading at ?1,680.25.',NULL,NULL,1040,0,'negative','2026-03-29 05:26:32');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_transfers`
--

DROP TABLE IF EXISTS `scheduled_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduled_transfers` (
  `transfer_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_account` varchar(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `frequency` enum('daily','weekly','monthly','yearly') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `next_execution_date` date DEFAULT NULL,
  `status` enum('active','cancelled','completed','paused') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transfer_id`),
  KEY `idx_scheduled_transfers_user_id` (`user_id`),
  KEY `idx_scheduled_transfers_status` (`status`),
  CONSTRAINT `fk_scheduled_transfers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_transfers`
--

LOCK TABLES `scheduled_transfers` WRITE;
/*!40000 ALTER TABLE `scheduled_transfers` DISABLE KEYS */;
INSERT INTO `scheduled_transfers` VALUES (1,'22222222-2222-2222-2222-222222222222','Home Rent','300000000001',12000.00,'monthly','2026-04-04','active','2026-03-30 05:26:31'),(2,'55555555-5555-5555-5555-555555555555','Parents Support','300000000002',15000.00,'monthly','2026-04-06','active','2026-03-30 05:26:31'),(3,'22222222-2222-2222-2222-222222222222','Home Rent','300000000001',12000.00,'monthly','2026-04-04','active','2026-03-30 05:44:39'),(4,'55555555-5555-5555-5555-555555555555','Parents Support','300000000002',15000.00,'monthly','2026-04-06','active','2026-03-30 05:44:39');
/*!40000 ALTER TABLE `scheduled_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `transaction_id` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_type` enum('credit','debit') COLLATE utf8mb4_unicode_ci NOT NULL,
  `merchant_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','completed','failed','reversed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completed',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `idx_transactions_account_id` (`account_id`),
  KEY `idx_transactions_created_at` (`created_at`),
  KEY `idx_transactions_status` (`status`),
  KEY `idx_transactions_reference_id` (`reference_id`),
  CONSTRAINT `fk_transactions_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_transactions_amount_positive` CHECK ((`amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES ('TXN100001',1,2500.00,'debit','Amazon','Online shopping purchase','REF-AMZ-1001','completed','2026-03-25 05:26:31'),('TXN100002',1,15000.00,'credit','Aditya Bank Payroll','Salary credit','REF-SAL-1002','completed','2026-03-20 05:26:31'),('TXN100003',2,1200.00,'debit','Zomato','Food order payment','REF-ZMT-1003','completed','2026-03-27 05:26:31'),('TXN100004',2,8000.00,'debit','Rent Transfer','Monthly house rent','REF-RNT-1004','completed','2026-03-23 05:26:31'),('TXN100005',3,25000.00,'credit','Client Payment','Business incoming transfer','REF-CLI-1005','completed','2026-03-22 05:26:31'),('TXN100006',4,5000.00,'debit','Big Bazaar','Shopping bill','REF-BBZ-1006','completed','2026-03-28 05:26:31'),('TXN100007',4,18000.00,'credit','Mutual Fund Redemption','Investment redemption','REF-MF-1007','completed','2026-03-18 05:26:31');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','customer','staff') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'customer',
  `dashboard_access` enum('none','view','edit') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#2563eb',
  `credit_score` int NOT NULL DEFAULT '700',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_number` (`account_number`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `chk_users_credit_score` CHECK ((`credit_score` between 300 and 900))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('11111111-1111-1111-1111-111111111111','10000001','System Administrator','admin@adityabank.com','9999999999','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','admin','edit','Aditya Bank Administration','#1a73e8',700,1,'2026-04-02 19:51:20','2026-03-30 05:26:31','2026-04-02 14:21:20'),('22222222-2222-2222-2222-222222222222','10000002','Rahul Sharma','rahul@example.com','9876543210','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','staff','edit','Retail Banking','#0ea5e9',760,1,'2026-03-31 15:26:29','2026-03-30 05:26:31','2026-03-31 09:56:29'),('33333333-3333-3333-3333-333333333333','10000003','Priya Mehta','priya@example.com','9876543211','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','customer','none','Loans','#f97316',720,1,'2026-03-31 16:37:27','2026-03-30 05:26:31','2026-03-31 11:07:27'),('44444444-4444-4444-4444-444444444444','10000004','Amit Verma','amit@example.com','9876543212','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','staff','edit','Customer Support','#22c55e',690,1,'2026-03-31 15:18:56','2026-03-30 05:26:31','2026-03-31 09:48:56'),('55555555-5555-5555-5555-555555555555','10000005','Sneha Patil','sneha@example.com','9876543213','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','customer','none','Investments','#a855f7',810,1,'2026-03-30 10:56:31','2026-03-30 05:26:31','2026-03-31 07:46:34'),('d58d621a-5700-4efa-b864-a1cd528562a9','7788599672','Arun Yadav','asd@gmail.com',NULL,'$2b$12$11RIGcu1wzyRd6/TeU.tPuOx0XGF4OGAH0VShJ1Lr6aWt0hlzRfwG','customer','view',NULL,'#1a73e8',700,1,'2026-03-31 14:56:34','2026-03-31 07:50:37','2026-03-31 09:26:34'),('e922f847-7f66-4d84-9c43-bdc18b28c3d2','200123456','Nikhil Chavan','axs@gmail.com',NULL,'$2b$12$2WG2ykc2ZFB.W9IUvV1W9O7tni5x3IjzQ2fr3eOA/u/uhAyJ8UAYa','customer','none',NULL,'#1a73e8',700,1,NULL,'2026-03-31 08:10:03','2026-03-31 08:10:03');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_backup`
--

DROP TABLE IF EXISTS `users_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_backup` (
  `id` bigint unsigned NOT NULL DEFAULT '0',
  `account_number` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','user','staff') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `dashboard_access` enum('none','view','edit') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#2563eb',
  `credit_score` int NOT NULL DEFAULT '700',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_backup`
--

LOCK TABLES `users_backup` WRITE;
/*!40000 ALTER TABLE `users_backup` DISABLE KEYS */;
INSERT INTO `users_backup` VALUES (1,'10000001','System Administrator','admin@infosys.com','9999999999','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','admin','edit','Administration','#1a73e8',700,1,'2026-03-30 10:18:53','2026-03-30 02:54:12','2026-03-30 04:48:53'),(2,'10000002','Rahul Sharma','rahul@example.com','9876543210','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','user','view','Retail Banking','#0ea5e9',760,1,NULL,'2026-03-30 02:54:12','2026-03-30 03:22:35'),(3,'10000003','Priya Mehta','priya@example.com','9876543211','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','user','view','Loans','#f97316',720,1,NULL,'2026-03-30 02:54:12','2026-03-30 03:22:35'),(4,'10000004','Amit Verma','amit@example.com','9876543212','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','staff','view','Customer Support','#22c55e',690,1,NULL,'2026-03-30 02:54:12','2026-03-30 04:53:55'),(5,'10000005','Sneha Patil','sneha@example.com','9876543213','$2b$12$gVnZAbSfh7EvT5mkcHhpf.Ht98TPnWwNoQi006A/kw8F3GD9ds2/W','user','view','Investments','#a855f7',810,1,NULL,'2026-03-30 02:54:12','2026-03-30 04:54:01');
/*!40000 ALTER TABLE `users_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_intent_stats`
--

DROP TABLE IF EXISTS `v_intent_stats`;
/*!50001 DROP VIEW IF EXISTS `v_intent_stats`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_intent_stats` AS SELECT 
 1 AS `intent`,
 1 AS `cnt`,
 1 AS `avg_conf_pct`,
 1 AS `avg_resp_ms`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_kpi`
--

DROP TABLE IF EXISTS `v_kpi`;
/*!50001 DROP VIEW IF EXISTS `v_kpi`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_kpi` AS SELECT 
 1 AS `total_users`,
 1 AS `new_today`,
 1 AS `total_sessions`,
 1 AS `total_messages`,
 1 AS `msg_today`,
 1 AS `avg_resp_ms`,
 1 AS `positive_fb`,
 1 AS `negative_fb`,
 1 AS `users_with_access`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_intent_stats`
--

/*!50001 DROP VIEW IF EXISTS `v_intent_stats`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_intent_stats` AS select `messages`.`intent` AS `intent`,count(0) AS `cnt`,round((avg(`messages`.`confidence`) * 100),2) AS `avg_conf_pct`,round(avg(`messages`.`response_time`),0) AS `avg_resp_ms` from `messages` where ((`messages`.`sender` = 'user') and (`messages`.`intent` is not null) and (`messages`.`intent` not in ('fallback','nlu_fallback'))) group by `messages`.`intent` order by `cnt` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_kpi`
--

/*!50001 DROP VIEW IF EXISTS `v_kpi`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_kpi` AS select (select count(0) from `users` where (`users`.`role` <> 'admin')) AS `total_users`,(select count(0) from `users` where ((`users`.`role` <> 'admin') and (cast(`users`.`created_at` as date) = curdate()))) AS `new_today`,(select count(0) from `chat_sessions`) AS `total_sessions`,(select count(0) from `messages`) AS `total_messages`,(select count(0) from `messages` where (cast(`messages`.`created_at` as date) = curdate())) AS `msg_today`,(select round(avg(`messages`.`response_time`),0) from `messages` where ((`messages`.`sender` = 'bot') and (`messages`.`response_time` is not null))) AS `avg_resp_ms`,(select count(0) from `feedback` where (`feedback`.`rating` = 'up')) AS `positive_fb`,(select count(0) from `feedback` where (`feedback`.`rating` = 'down')) AS `negative_fb`,(select count(0) from `users` where ((`users`.`dashboard_access` <> 'none') and (`users`.`role` <> 'admin'))) AS `users_with_access` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-02 22:16:39
