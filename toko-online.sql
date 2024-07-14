-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 14, 2024 at 02:17 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `toko-online`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_HitungJumlahPembeli` ()   BEGIN
    DECLARE jumlah INT;
    DECLARE pesan VARCHAR(255);
    SELECT COUNT(*) INTO jumlah FROM pembeli;
    
    IF jumlah = 0 THEN
        SET pesan = 'Tidak ada pembeli ditemukan.';
    ELSE
        SET pesan = CONCAT('Total pembeli: ', jumlah);
    END IF;
    
    SELECT pesan AS hasil;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_HitungTotalPembeliaPerjenis` (`p_kode_bank` VARCHAR(20), `p_jenis_barang` VARCHAR(20))   BEGIN
    CASE 
        WHEN p_jenis_barang = 'laptop' THEN
            SELECT SUM(m.jumlah) as total_pembelian
            FROM membeli m
            JOIN barang b ON m.sku = b.sku
            JOIN barang_laptop bl ON b.sku = bl.sku
            WHERE m.kode_bank = p_kode_bank;
        WHEN p_jenis_barang = 'pakaian' THEN
            SELECT SUM(m.jumlah) as total_pembelian
            FROM membeli m
            JOIN barang b ON m.sku = b.sku
            JOIN barang_pakaian bp ON b.sku = bp.sku
            WHERE m.kode_bank = p_kode_bank;
        ELSE
        	SELECT 0 AS total_pembelian;
    END CASE;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_AmbilJumlahPembeli` () RETURNS INT(11)  BEGIN
    DECLARE jumlah INT;
    SELECT COUNT(*) INTO jumlah FROM pembeli;
    RETURN jumlah;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_NamaBarang` (`p_sku` VARCHAR(255), `p_EmailPenjual` VARCHAR(255)) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE nama_barang TEXT;
    SELECT nama INTO nama_barang FROM barang WHERE sku = p_sku AND email_penjual = p_EmailPenjual;
    RETURN nama_barang;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alamat`
--

CREATE TABLE `alamat` (
  `kode` int(4) NOT NULL,
  `email_pembeli` varchar(255) DEFAULT NULL,
  `jalan` text DEFAULT NULL,
  `kota` text DEFAULT NULL,
  `provinsi` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alamat`
--

INSERT INTO `alamat` (`kode`, `email_pembeli`, `jalan`, `kota`, `provinsi`) VALUES
(1001, 'john.doe@example.com', '123 Main St', 'City A', 'Province A'),
(1002, 'jane.smith@example.com', '456 Oak St', 'City B', 'Province B'),
(1003, 'alice.jones@example.com', '789 Pine St', 'City C', 'Province C'),
(1004, 'bob.brown@example.com', '321 Maple St', 'City D', 'Province D'),
(1005, 'carol.white@example.com', '654 Cedar St', 'City E', 'Province E');

-- --------------------------------------------------------

--
-- Table structure for table `bank`
--

CREATE TABLE `bank` (
  `kode_bank` varchar(20) NOT NULL,
  `nama` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bank`
--

INSERT INTO `bank` (`kode_bank`, `nama`) VALUES
('B001', 'Bank A'),
('B002', 'Bank B'),
('B003', 'Bank C'),
('B004', 'Bank D'),
('B005', 'Bank E');

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `sku` varchar(255) NOT NULL,
  `email_penjual` varchar(255) DEFAULT NULL,
  `nama` text DEFAULT NULL,
  `harga` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`sku`, `email_penjual`, `nama`, `harga`) VALUES
('sku001', 'seller1@example.com', 'Laptop A', 2000),
('sku002', 'seller2@example.com', 'Laptop B', 1500),
('sku003', 'seller3@example.com', 'Pakaian A', 1200),
('sku004', 'seller4@example.com', 'Pakaian B', 700),
('sku005', 'seller5@example.com', 'Laptop C', 2500),
('sku006', 'seller1@example.com', 'Laptop D', 3500),
('sku007', 'seller2@example.com', 'Laptop E', 1800),
('sku008', 'seller3@example.com', 'Laptop F', 1000),
('sku009', 'seller4@example.com', 'Laptop G', 4000),
('sku010', 'seller5@example.com', 'Laptop H', 2200),
('sku011', 'seller1@example.com', 'Pakaian C', 600),
('sku012', 'seller2@example.com', 'Pakaian D', 550),
('sku013', 'seller3@example.com', 'Pakaian E', 700),
('sku014', 'seller4@example.com', 'Pakaian F', 800),
('sku015', 'seller5@example.com', 'Pakaian G', 900),
('sku016', 'seller2@example.com', 'Pakaian H', 1200),
('sku017', 'seller2@example.com', 'Pakaian H', 1100),
('sku019', 'seller5@example.com', NULL, NULL),
('sku020', 'seller1@example.com', 'LAPTOP Z', 5000);

--
-- Triggers `barang`
--
DELIMITER $$
CREATE TRIGGER `after_update_barang` AFTER UPDATE ON `barang` FOR EACH ROW BEGIN
    INSERT INTO log_barang VALUES (NEW.sku, 'AFTER UPDATE', NEW.nama, NEW.harga, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_barang` BEFORE DELETE ON `barang` FOR EACH ROW BEGIN
    INSERT INTO log_barang VALUES (OLD.sku, 'BEFORE DELETE', OLD.nama, OLD.harga, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_barang` BEFORE INSERT ON `barang` FOR EACH ROW BEGIN
    INSERT INTO log_barang VALUES ( NEW.sku,'BEFORE INSERT', NEW.nama, NEW.harga, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_barang` BEFORE UPDATE ON `barang` FOR EACH ROW BEGIN
    INSERT INTO log_barang VALUES (OLD.sku, 'BEFORE UPDATE', OLD.nama, OLD.harga, NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `barang_laptop`
--

CREATE TABLE `barang_laptop` (
  `sku` varchar(255) NOT NULL,
  `cpu` text DEFAULT NULL,
  `ram` text DEFAULT NULL,
  `disk` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang_laptop`
--

INSERT INTO `barang_laptop` (`sku`, `cpu`, `ram`, `disk`) VALUES
('sku001', 'Intel i7', '16GB', '512GB SSD'),
('sku002', 'Intel i5', '8GB', '256GB SSD'),
('sku005', 'AMD Ryzen 7', '16GB', '1TB SSD'),
('sku006', 'Intel i9', '32GB', '1TB SSD'),
('sku007', 'AMD Ryzen 5', '16GB', '512GB SSD'),
('sku008', 'Intel i3', '8GB', '256GB SSD'),
('sku009', 'AMD Ryzen 9', '32GB', '2TB SSD'),
('sku010', 'Intel i5', '16GB', '1TB SSD');

-- --------------------------------------------------------

--
-- Table structure for table `barang_pakaian`
--

CREATE TABLE `barang_pakaian` (
  `sku` varchar(255) NOT NULL,
  `ukuran` text DEFAULT NULL,
  `warna` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang_pakaian`
--

INSERT INTO `barang_pakaian` (`sku`, `ukuran`, `warna`) VALUES
('sku003', 'M', 'Red'),
('sku004', 'L', 'Blue'),
('sku011', 'S', 'Green'),
('sku012', 'M', 'Yellow'),
('sku013', 'L', 'Black'),
('sku014', 'XL', 'White'),
('sku015', 'XXL', 'Pink');

-- --------------------------------------------------------

--
-- Table structure for table `barang_tas`
--

CREATE TABLE `barang_tas` (
  `sku` varchar(255) NOT NULL,
  `warna` varchar(255) DEFAULT NULL,
  `bahan` varchar(255) DEFAULT NULL,
  `jenis_tas` enum('Backpack','Shoulder Bag','Handbag','Clutch','Tote') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dompet`
--

CREATE TABLE `dompet` (
  `id_dompet` int(11) NOT NULL,
  `email_pembeli` varchar(255) DEFAULT NULL,
  `saldo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dompet`
--

INSERT INTO `dompet` (`id_dompet`, `email_pembeli`, `saldo`) VALUES
(1, 'john.doe@example.com', 1000),
(2, 'jane.smith@example.com', 2000),
(3, 'alice.jones@example.com', 3000),
(4, 'bob.brown@example.com', 4000),
(5, 'carol.white@example.com', 4000);

-- --------------------------------------------------------

--
-- Stand-in structure for view `induk_view`
-- (See below for the actual view)
--
CREATE TABLE `induk_view` (
`sku` varchar(255)
,`email_penjual` varchar(255)
,`nama` text
,`harga` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `log_barang`
--

CREATE TABLE `log_barang` (
  `sku` varchar(255) DEFAULT NULL,
  `event_type` varchar(50) DEFAULT NULL,
  `nama` text DEFAULT NULL,
  `harga` int(11) DEFAULT NULL,
  `date_modified` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_barang`
--

INSERT INTO `log_barang` (`sku`, `event_type`, `nama`, `harga`, `date_modified`) VALUES
('sku016', 'BEFORE INSERT', 'Pakaian H', 550, '2024-07-11'),
('sku016', 'BEFORE UPDATE', 'Pakaian H', 550, '2024-07-11'),
('sku016', 'BEFORE DELETE', 'Pakaian H', 1500, '2024-07-11'),
('sku015', 'BEFORE UPDATE', 'Pakaian G', 650, '2024-07-11'),
('sku015', 'BEFORE UPDATE', 'Pakaian G', 900, '2024-07-11'),
('sku001', 'BEFORE UPDATE', 'Laptop A', 1500, '2024-07-11'),
('sku001', 'AFTER UPDATE', 'Laptop A', 2000, '2024-07-11'),
('sku003', 'BEFORE UPDATE', 'Pakaian A', 500, '2024-07-11'),
('sku003', 'AFTER UPDATE', 'Pakaian A', 1500, '2024-07-11'),
('sku016', 'BEFORE INSERT', 'Pakaian H', 1200, '2024-07-11'),
('sku002', 'BEFORE UPDATE', 'Laptop B', 2000, '2024-07-12'),
('sku002', 'AFTER UPDATE', 'Laptop B', 1500, '2024-07-12'),
('sku017', 'BEFORE INSERT', 'Pakaian H', 1100, '2024-07-12'),
('sku018', 'BEFORE INSERT', NULL, NULL, '2024-07-12'),
('sku018', 'BEFORE UPDATE', NULL, NULL, '2024-07-12'),
('sku019', 'AFTER UPDATE', NULL, NULL, '2024-07-12'),
('sku003', 'BEFORE UPDATE', 'Pakaian A', 1500, '2024-07-12'),
('sku003', 'AFTER UPDATE', 'Pakaian A', 1200, '2024-07-12'),
('sku020', 'BEFORE INSERT', 'LAPTOP Z', 5000, '2024-07-12');

-- --------------------------------------------------------

--
-- Table structure for table `log_menyukai`
--

CREATE TABLE `log_menyukai` (
  `event_type` varchar(50) DEFAULT NULL,
  `email_pembeli` varchar(255) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `date_modified` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_menyukai`
--

INSERT INTO `log_menyukai` (`event_type`, `email_pembeli`, `sku`, `date_modified`) VALUES
('AFTER DELETE', 'john.doe@example.com', 'sku001', '2024-07-11');

-- --------------------------------------------------------

--
-- Table structure for table `membeli`
--

CREATE TABLE `membeli` (
  `sku` varchar(255) DEFAULT NULL,
  `email_pembeli` varchar(255) DEFAULT NULL,
  `kode_bank` varchar(20) DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membeli`
--

INSERT INTO `membeli` (`sku`, `email_pembeli`, `kode_bank`, `jumlah`) VALUES
('sku001', 'john.doe@example.com', 'B001', 1),
('sku002', 'jane.smith@example.com', 'B002', 2),
('sku003', 'alice.jones@example.com', 'B003', 1),
('sku004', 'bob.brown@example.com', 'B004', 3),
('sku005', 'carol.white@example.com', 'B005', 1),
('sku003', 'alice.jones@example.com', 'B003', 1),
('sku001', 'bob.brown@example.com', 'B004', 2),
('sku005', 'carol.white@example.com', 'B005', 1),
('sku002', 'jane.smith@example.com', 'B002', 1),
('sku003', 'carol.white@example.com', 'B005', 2);

--
-- Triggers `membeli`
--
DELIMITER $$
CREATE TRIGGER `after_insert_membeli` AFTER INSERT ON `membeli` FOR EACH ROW BEGIN
    DECLARE saldo_awal INT;
    DECLARE saldo_baru INT;
    
    SELECT saldo INTO saldo_awal
    FROM dompet
    WHERE email_pembeli = NEW.email_pembeli;
    
    SET saldo_baru = saldo_awal - (NEW.jumlah * (SELECT harga FROM barang WHERE sku = NEW.sku));
    
    UPDATE dompet
    SET saldo = saldo_baru
    WHERE email_pembeli = NEW.email_pembeli;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `menyukai`
--

CREATE TABLE `menyukai` (
  `email_pembeli` varchar(255) NOT NULL,
  `sku` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `menyukai`
--

INSERT INTO `menyukai` (`email_pembeli`, `sku`) VALUES
('alice.jones@example.com', 'sku003'),
('bob.brown@example.com', 'sku004'),
('carol.white@example.com', 'sku005'),
('jane.smith@example.com', 'sku002');

--
-- Triggers `menyukai`
--
DELIMITER $$
CREATE TRIGGER `after_delete_menyukai` AFTER DELETE ON `menyukai` FOR EACH ROW BEGIN
    
    INSERT INTO log_menyukai VALUES ('AFTER DELETE', OLD.email_pembeli, OLD.sku, NOW()); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pembeli`
--

CREATE TABLE `pembeli` (
  `email_pembeli` varchar(255) NOT NULL,
  `nama` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pembeli`
--

INSERT INTO `pembeli` (`email_pembeli`, `nama`) VALUES
('alice.jones@example.com', 'Alice Jones'),
('bob.brown@example.com', 'Bob Brown'),
('carol.white@example.com', 'Carol White'),
('jane.smith@example.com', 'Jane Smith'),
('john.doe@example.com', 'John Doe');

-- --------------------------------------------------------

--
-- Table structure for table `penjual`
--

CREATE TABLE `penjual` (
  `email_penjual` varchar(255) NOT NULL,
  `nama` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `penjual`
--

INSERT INTO `penjual` (`email_penjual`, `nama`) VALUES
('seller1@example.com', 'Seller One'),
('seller2@example.com', 'Seller Two'),
('seller3@example.com', 'Seller Three'),
('seller4@example.com', 'Seller Four'),
('seller5@example.com', 'Seller Five');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_barang`
-- (See below for the actual view)
--
CREATE TABLE `v_barang` (
`sku` varchar(255)
,`email_penjual` varchar(255)
,`nama` text
,`harga` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_barang_all`
-- (See below for the actual view)
--
CREATE TABLE `v_barang_all` (
`sku` varchar(255)
,`email_penjual` varchar(255)
,`nama` text
,`harga` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_barang_limited`
-- (See below for the actual view)
--
CREATE TABLE `v_barang_limited` (
`sku` varchar(255)
,`email_penjual` varchar(255)
);

-- --------------------------------------------------------

--
-- Structure for view `induk_view`
--
DROP TABLE IF EXISTS `induk_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `induk_view`  AS SELECT `v_barang`.`sku` AS `sku`, `v_barang`.`email_penjual` AS `email_penjual`, `v_barang`.`nama` AS `nama`, `v_barang`.`harga` AS `harga` FROM `v_barang`WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `v_barang`
--
DROP TABLE IF EXISTS `v_barang`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_barang`  AS SELECT `barang`.`sku` AS `sku`, `barang`.`email_penjual` AS `email_penjual`, `barang`.`nama` AS `nama`, `barang`.`harga` AS `harga` FROM `barang` WHERE `barang`.`harga` > 1000 ;

-- --------------------------------------------------------

--
-- Structure for view `v_barang_all`
--
DROP TABLE IF EXISTS `v_barang_all`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_barang_all`  AS SELECT `barang`.`sku` AS `sku`, `barang`.`email_penjual` AS `email_penjual`, `barang`.`nama` AS `nama`, `barang`.`harga` AS `harga` FROM `barang` WHERE `barang`.`email_penjual` = 'seller2@example.com' ;

-- --------------------------------------------------------

--
-- Structure for view `v_barang_limited`
--
DROP TABLE IF EXISTS `v_barang_limited`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_barang_limited`  AS SELECT `barang`.`sku` AS `sku`, `barang`.`email_penjual` AS `email_penjual` FROM `barang` WHERE `barang`.`email_penjual` = 'seller5@example.com' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alamat`
--
ALTER TABLE `alamat`
  ADD PRIMARY KEY (`kode`),
  ADD KEY `email_pembeli` (`email_pembeli`);

--
-- Indexes for table `bank`
--
ALTER TABLE `bank`
  ADD PRIMARY KEY (`kode_bank`);

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`sku`),
  ADD KEY `email_penjual` (`email_penjual`),
  ADD KEY `idx_barang` (`email_penjual`(100),`nama`(100));

--
-- Indexes for table `barang_laptop`
--
ALTER TABLE `barang_laptop`
  ADD PRIMARY KEY (`sku`);

--
-- Indexes for table `barang_pakaian`
--
ALTER TABLE `barang_pakaian`
  ADD PRIMARY KEY (`sku`),
  ADD KEY `idx_BarangPakaian` (`ukuran`(100),`warna`(100));

--
-- Indexes for table `barang_tas`
--
ALTER TABLE `barang_tas`
  ADD PRIMARY KEY (`sku`),
  ADD KEY `idx_BarangTas` (`jenis_tas`,`warna`);

--
-- Indexes for table `dompet`
--
ALTER TABLE `dompet`
  ADD PRIMARY KEY (`id_dompet`),
  ADD UNIQUE KEY `email_pembeli` (`email_pembeli`);

--
-- Indexes for table `membeli`
--
ALTER TABLE `membeli`
  ADD KEY `sku` (`sku`),
  ADD KEY `email_pembeli` (`email_pembeli`),
  ADD KEY `kode_bank` (`kode_bank`);

--
-- Indexes for table `menyukai`
--
ALTER TABLE `menyukai`
  ADD PRIMARY KEY (`email_pembeli`,`sku`),
  ADD KEY `sku` (`sku`);

--
-- Indexes for table `pembeli`
--
ALTER TABLE `pembeli`
  ADD PRIMARY KEY (`email_pembeli`);

--
-- Indexes for table `penjual`
--
ALTER TABLE `penjual`
  ADD PRIMARY KEY (`email_penjual`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dompet`
--
ALTER TABLE `dompet`
  MODIFY `id_dompet` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alamat`
--
ALTER TABLE `alamat`
  ADD CONSTRAINT `alamat_ibfk_1` FOREIGN KEY (`email_pembeli`) REFERENCES `pembeli` (`email_pembeli`);

--
-- Constraints for table `barang`
--
ALTER TABLE `barang`
  ADD CONSTRAINT `barang_ibfk_1` FOREIGN KEY (`email_penjual`) REFERENCES `penjual` (`email_penjual`);

--
-- Constraints for table `barang_laptop`
--
ALTER TABLE `barang_laptop`
  ADD CONSTRAINT `barang_laptop_ibfk_1` FOREIGN KEY (`sku`) REFERENCES `barang` (`sku`);

--
-- Constraints for table `barang_pakaian`
--
ALTER TABLE `barang_pakaian`
  ADD CONSTRAINT `barang_pakaian_ibfk_1` FOREIGN KEY (`sku`) REFERENCES `barang` (`sku`);

--
-- Constraints for table `barang_tas`
--
ALTER TABLE `barang_tas`
  ADD CONSTRAINT `barang_tas_ibfk_1` FOREIGN KEY (`sku`) REFERENCES `barang` (`sku`);

--
-- Constraints for table `dompet`
--
ALTER TABLE `dompet`
  ADD CONSTRAINT `dompet_ibfk_1` FOREIGN KEY (`email_pembeli`) REFERENCES `pembeli` (`email_pembeli`);

--
-- Constraints for table `membeli`
--
ALTER TABLE `membeli`
  ADD CONSTRAINT `membeli_ibfk_1` FOREIGN KEY (`sku`) REFERENCES `barang` (`sku`),
  ADD CONSTRAINT `membeli_ibfk_2` FOREIGN KEY (`email_pembeli`) REFERENCES `pembeli` (`email_pembeli`),
  ADD CONSTRAINT `membeli_ibfk_3` FOREIGN KEY (`kode_bank`) REFERENCES `bank` (`kode_bank`);

--
-- Constraints for table `menyukai`
--
ALTER TABLE `menyukai`
  ADD CONSTRAINT `menyukai_ibfk_1` FOREIGN KEY (`email_pembeli`) REFERENCES `pembeli` (`email_pembeli`),
  ADD CONSTRAINT `menyukai_ibfk_2` FOREIGN KEY (`sku`) REFERENCES `barang` (`sku`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
