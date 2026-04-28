-- -----------------------------------------------------
-- DATABASE SETUP
-- -----------------------------------------------------
DROP DATABASE IF EXISTS `ExScent`;
CREATE DATABASE `ExScent`;
USE `ExScent`;

-- -----------------------------------------------------
-- 1. ADMIN
-- -----------------------------------------------------
CREATE TABLE `Admin` (
    `admin_id` VARCHAR(10) NOT NULL,
    `address` VARCHAR(200),
    `email` VARCHAR(50) NOT NULL,
    `f_name` VARCHAR(50) NOT NULL,
    `l_name` VARCHAR(50) NOT NULL,
    `age` INT,
    
    CONSTRAINT PK_Admin PRIMARY KEY (admin_id),
    CONSTRAINT UQ_Admin_Email UNIQUE (email),
    CONSTRAINT CHK_Admin_Age CHECK (age BETWEEN 18 AND 60)
);

-- -----------------------------------------------------
-- 2. CUSTOMER
-- -----------------------------------------------------
CREATE TABLE `Customer` (
    `customer_id` VARCHAR(10) NOT NULL,
    `address` VARCHAR(200) NOT NULL,
    `email` VARCHAR(50) NOT NULL,
    `f_name` VARCHAR(50) NOT NULL,
    `l_name` VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Customer PRIMARY KEY (customer_id),
    CONSTRAINT UQ_Customer_Email UNIQUE (email)
);

-- -----------------------------------------------------
-- 3. PRODUCT
-- -----------------------------------------------------
CREATE TABLE `Product` (
    `product_id` VARCHAR(20) NOT NULL,
    `product_name` VARCHAR(100) NOT NULL,
    `product_price` DECIMAL(10,2) NOT NULL,
    `product_detail` VARCHAR(255),
    `product_status` ENUM(
        'Active',
        'Disabled'
    ) NOT NULL,
    `admin_id` VARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Product PRIMARY KEY (product_id),
    CONSTRAINT FK_Product_Admin FOREIGN KEY (admin_id)
        REFERENCES Admin(admin_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CHK_Product_Price CHECK (product_price > 0)
);

-- -----------------------------------------------------
-- 4. ORDERS (renamed from Order)
-- -----------------------------------------------------
CREATE TABLE `Orders` (
    `order_id` VARCHAR(10) NOT NULL,
    `order_status` VARCHAR(50) NOT NULL,
    `total_amount` DECIMAL(10,2) NOT NULL,
    `order_date` DATE NOT NULL,
    `customer_id` VARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Orders PRIMARY KEY (order_id),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CHK_Total_Amount CHECK (total_amount > 0)
);

-- -----------------------------------------------------
-- 5. PAYMENT (removed customer_id)
-- -----------------------------------------------------
CREATE TABLE `Payment` (
    `payment_id` VARCHAR(10) NOT NULL,
    `vat` DECIMAL(10,2) NOT NULL,
    `total_price` DECIMAL(10,2) NOT NULL,
    `payment_date` DATE NOT NULL,
    `order_id` VARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Payment PRIMARY KEY (payment_id),
    CONSTRAINT FK_Payment_Order FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CHK_VAT CHECK (vat > 0),
    CONSTRAINT CHK_Total_Price CHECK (total_price > 0)
);

-- -----------------------------------------------------
-- 6. DELIVERY
-- -----------------------------------------------------
CREATE TABLE `Delivery` (
    `delivery_id` VARCHAR(10) NOT NULL,
    `delivered_date` DATE,
    `shipping_date` DATE NOT NULL,
    `delivery_address` VARCHAR(200) NOT NULL,
    `delivery_status` VARCHAR(50) NOT NULL,
    `track_num` VARCHAR(50),
    `order_id` VARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Delivery PRIMARY KEY (delivery_id),
    CONSTRAINT FK_Delivery_Order FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- 7. ADMIN LOGIN
-- -----------------------------------------------------
CREATE TABLE `Admin_login` (
    `login_id` VARCHAR(10) NOT NULL,
    `username` VARCHAR(50) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `role` VARCHAR(50) NOT NULL,
    `admin_id` VARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Admin_login PRIMARY KEY (login_id),
    CONSTRAINT UQ_Username UNIQUE (username),
    CONSTRAINT FK_Login_Admin FOREIGN KEY (admin_id)
        REFERENCES Admin(admin_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- 8. CONTAINS (added quantity)
-- -----------------------------------------------------
CREATE TABLE `Contains` (
    `order_id` VARCHAR(10) NOT NULL,
    `product_id` VARCHAR(20) NOT NULL,
    `quantity` INT NOT NULL,
    
    CONSTRAINT PK_Contains PRIMARY KEY (order_id, product_id),
    CONSTRAINT FK_Contains_Order FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_Contains_Product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CHK_Quantity CHECK (quantity > 0)
);

-- -----------------------------------------------------
-- 9. CARD (secured)
-- -----------------------------------------------------
CREATE TABLE `Card` (
    `payment_id` VARCHAR(10) NOT NULL,
    `card_last4` CHAR(4) NOT NULL,
    `expiration_date` DATE NOT NULL,
    `holder_name` VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Card PRIMARY KEY (payment_id),
    CONSTRAINT FK_Card_Payment FOREIGN KEY (payment_id)
        REFERENCES Payment(payment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- 10. BANK TRANSFER
-- -----------------------------------------------------
CREATE TABLE `Bank_Transfer` (
    `payment_id` VARCHAR(10) NOT NULL,
    `bank_account` VARCHAR(20) NOT NULL,
    `bank_name` VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Bank_Transfer PRIMARY KEY (payment_id),
    CONSTRAINT FK_BankTransfer_Payment FOREIGN KEY (payment_id)
        REFERENCES Payment(payment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- 11. PERFUME
-- -----------------------------------------------------
CREATE TABLE `Perfume` (
    `perfume_id` VARCHAR(10) NOT NULL,
    `concentration` ENUM(
        'PARFUM',
        'EAU DE PARFUM',
        'EAU DE TOILETTE',
        'EAU DE COLOGNE'
    ) NOT NULL,
    `rating` DECIMAL(3,2) NOT NULL,
    `votes` INT DEFAULT 0,
    `brand` VARCHAR(50) NOT NULL,
    `gender` ENUM('Unisex', 'Feminine', 'Masculine') NOT NULL,
    `product_id` VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Perfume PRIMARY KEY (perfume_id),
    CONSTRAINT FK_Perfume_Product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CHK_Perfume_Rating CHECK (rating BETWEEN 0 AND 5)
);

-- -----------------------------------------------------
-- 12. PRODUCT IMAGE
-- -----------------------------------------------------
CREATE TABLE `Product_Image` (
    `image_id` INT AUTO_INCREMENT NOT NULL,
    `image_url` VARCHAR(255) NOT NULL,
    `is_primary` BOOLEAN DEFAULT FALSE,
    `product_id` VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Product_Image PRIMARY KEY (image_id),
    CONSTRAINT FK_ProductImage_Product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- 11. PRODUCT VARIANT (New Table for Multiple Volumes)
-- -----------------------------------------------------
CREATE TABLE `Product_Variant` (
    `variant_id` INT AUTO_INCREMENT NOT NULL,
    `product_id` VARCHAR(20) NOT NULL,
    `volume` INT NOT NULL,
    `price` DECIMAL(10,2) NOT NULL,
    `stock` INT NOT NULL DEFAULT 0,
    
    CONSTRAINT PK_Product_Variant PRIMARY KEY (variant_id),
    CONSTRAINT FK_Variant_Product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- INSERT DATA
-- -----------------------------------------------------

INSERT INTO Admin VALUES
('000035', 'Sathorn, Bangkok', 'thung@test.com', 'Pratanin', 'Kahtepmud', 20),
('000070', 'Bang Yai, Nonthaburi', 'phukao@test.com', 'Achita', 'Niljumrus', 20),
('000150', 'Bang Pa-in, Ayutthaya', 'view@test.com', 'Amornpol', 'Champasakul', 20),
('000154', 'Bang Yai, Nonthaburi', 'tigger@test.com', 'Palabordin', 'Suaiam', 20),
('000209', 'Thawi Watthana, Bangkok', 'note@test.com', 'Boonyasak', 'Reangwongngam', 20);

INSERT INTO Product VALUES
('6703227867003', 'Dior homme intense', 5720.00, 'Top Notes : Iris\nMiddle Notes : Ambrette\nBottom Notes : Cedar', 'Active', '000035'),
('1738478326521', 'Soleil Neige', '6435.00', 'Top notes: Bergamot, Carrot Seeds\nMiddle notes: White Flowers, Orange Blossom, Jasmine, Rose, Turkish Rose\nBase notes: Benzoin, Vanilla, Labdanum', 'Active', '000035'),
('3886177383183', 'Luna Rossa Sport', '4950.00', 'Top notes: Juniper Berries, Ginger\nMiddle note: Lavender\nBase notes: Vanilla, Tonka Bean', 'Active', '000035'),
('4846676644071', 'Donna Born In Roma Yellow Dream', '7300.00', 'Top note: Lemon\nMiddle note: Rose\nBase note: White Musk', 'Active', '000035'),
('4870270827970', 'Armani Code Le Parfum', '5568.00', 'Top notes: bergamot, bergamot leaf\nHeart: orris butter, iris aldehyde, clary sage\nBase: tonka bean, cedar ', 'Active', '000035'),
('5655062908095', 'Stronger With You Parfum', '4400.00', 'Top notes: Pink Pepper and Mandarin\nMiddle notes: Lavender, Cinnamon and Sage\nBase notes: Chestnut, Vanilla and Leather', 'Active', '000035'),
('5865518889480', 'Gris Charnel', '7600.00', 'Top notes: Cardamom, Fig, Black Tea\nMiddle notes: Iris, Bourbon Vetiver\nBase notes: Sandalwood, Tonka Bean', 'Active', '000035'),
('5906877693792', 'Bleu de Chanel', '110.00', 'Woody aromatic fragrance', 'Active', '000035'),
('6644093067615', 'MYSLF L''Absolu', '6290.00', 'Top notes: Ginger, Bergamot, Cardamom\nMiddle notes: Orange Blossom, Floral Notes\nBase note: Patchouli', 'Active', '000035'),
('8357223767340', 'Boss Bottled Beyond', '4667.00', 'Top note: Ginger\nMiddle note: Leather\nBase note: Woody Notes', 'Active', '000035'),
('9439369400279', 'Le Vestiaire Des Parfums Blouse', '10350.00', 'Top notes: Bergamot, Galbanum, Pink Pepper\nMiddle notes: Damask Rose, Angelica\nBase notes: White Musk, Cashmeran', 'Active', '000035'),
('9784839464339', 'Luna Rossa Black', '4200.00', 'Top note: Bergamot\nMiddle notes: Angelica, Patchouli\nBase notes: Coumarin, Amber, Musk', 'Active', '000035');

INSERT INTO Product_Image (image_url, is_primary, product_id) VALUES
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS6340%2Fdior-diorhommeintenseeaudeparfumintense100ml-CDS6340728-1.webp&w=1080&q=75', 1, '6703227867003'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS6340%2Fdior-diorhommeintenseeaudeparfumintense100ml-CDS6340728-3.webp&w=1080&q=75', 0, '6703227867003'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS6340%2Fdior-diorhommeintenseeaudeparfumintense100ml-CDS6340728-6.webp&w=1080&q=75', 0, '6703227867003'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS9572%2FGIORGIO_ARMANI-MenFragranceArmaniCodeLeParfum75mL-CDS95721071-1.webp&w=1080&q=75', 1, '4870270827970'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS9572%2FGIORGIO_ARMANI-MenFragranceArmaniCodeLeParfum75mL-CDS95721071-4.webp&w=1080&q=75', 0, '4870270827970'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS9572%2FGIORGIO_ARMANI-MenFragranceArmaniCodeLeParfum75mL-CDS95721071-5.webp&w=1080&q=75', 0, '4870270827970'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS9572%2FGIORGIO_ARMANI-MenFragranceArmaniCodeLeParfum75mL-CDS95721071-6.webp&w=1080&q=75', 0, '4870270827970'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS1877%2FGIORGIOARMANI-MENFRAGRANCESTRONGERWITHYOUPARFUM100ML-CDS18774047-1.webp&w=1080&q=75', 1, '5655062908095'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS1877%2Fgiorgioarmani-menfragrancestrongerwithyouparfum-CDS18774047-3.webp&w=1080&q=75', 0, '5655062908095'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS1877%2Fgiorgioarmani-menfragrancestrongerwithyouparfum-CDS18774047-8.webp&w=1080&q=75', 0, '5655062908095'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS1877%2Fgiorgioarmani-menfragrancestrongerwithyouparfum-CDS18774047-9.webp&w=1080&q=75', 0, '5655062908095'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS1877%2Fgiorgioarmani-menfragrancestrongerwithyouparfum-CDS18774047-2.webp&w=1080&q=75', 0, '5655062908095'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS8712%2FVALENTINO-DonnaBornInRomaYellowDreamEDPFemale100mL-CDS87122800-1.webp&w=1080&q=75', 1, '4846676644071'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS8712%2FVALENTINO-DonnaBornInRomaYellowDreamEDPFemale100mL-CDS87122800-2.webp&w=1080&q=75', 0, '4846676644071'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS8712%2FVALENTINO-DonnaBornInRomaYellowDreamEDPFemale100mL-CDS87122800-3.webp&w=1080&q=75', 0, '4846676644071'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2529%2FBDKPARFUMS-GRISCHARNELEDP100ML-CDS25292916-1.webp&w=1080&q=75', 1, '5865518889480'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS1682%2FPRADA-PradaLunaRossaBlackEdp50mLMale-CDS16821439-1.webp&w=1080&q=75', 1, '9784839464339'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS8910%2FPRADA-PradaLunaRossaSportEdt100mLMale-CDS89103951-1.webp&w=1080&q=75', 1, '3886177383183'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2680%2FTOMFORDBEAUTY-SOLEILNEIGEEDP50ML-CDS26803012-1.webp&w=1080&q=75', 1, '1738478326521'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2680%2FTOMFORDBEAUTY-SOLEILNEIGEEDP50ML-CDS26803012-3.webp&w=1080&q=75', 0, '1738478326521'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2318%2Fyslbeauty-unisexfragrancelevestiairedesparfumsblouseeaudeparfum125ml-CDS23184947-1.webp&w=1080&q=75', 1, '9439369400279'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2318%2Fyslbeauty-unisexfragrancelevestiairedesparfumsblouseeaudeparfum125ml-CDS23184947-2.webp&w=1080&q=75', 0, '9439369400279'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2318%2Fyslbeauty-unisexfragrancelevestiairedesparfumsblouseeaudeparfum125ml-CDS23184947-4.webp&w=1080&q=75', 0, '9439369400279'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2318%2Fyslbeauty-unisexfragrancelevestiairedesparfumsblouseeaudeparfum125ml-CDS23184947-5.webp&w=1080&q=75', 0, '9439369400279'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2318%2Fyslbeauty-unisexfragrancelevestiairedesparfumsblouseeaudeparfum125ml-CDS23184947-6.webp&w=1080&q=75', 0, '9439369400279'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2332%2Fyslbeauty-menfragrancemyslflabsolu100ml-CDS23329980-1.webp&w=1080&q=75', 1, '6644093067615'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2332%2Fyslbeauty-menfragrancemyslflabsolu100ml-CDS23329980-3.webp&w=1080&q=75', 0, '6644093067615'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2332%2Fyslbeauty-menfragrancemyslflabsolu100ml-CDS23329980-6.webp&w=1080&q=75', 0, '6644093067615'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2480%2FHUGOBOSS-MENFRAGRANCEBOSSBOTTLEDBEYONDEAUDEPARFUM100ML-CDS24802130-1.webp&w=1080&q=75', 1, '8357223767340'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2480%2FHUGOBOSS-MENFRAGRANCEBOSSBOTTLEDBEYONDEAUDEPARFUM100ML-CDS24802130-3.webp&w=1080&q=75', 0, '8357223767340'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2480%2FHUGOBOSS-MENFRAGRANCEBOSSBOTTLEDBEYONDEAUDEPARFUM100ML-CDS24802130-7.webp&w=1080&q=75', 0, '8357223767340'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2480%2FHUGOBOSS-MENFRAGRANCEBOSSBOTTLEDBEYONDEAUDEPARFUM100ML-CDS24802130-10.webp&w=1080&q=75', 0, '8357223767340'),
('https://www.central.co.th/_next/image?url=https%3A%2F%2Fassets.central.co.th%2Ffile-assets%2FCDSPIM%2Fweb%2FImage%2FCDS2480%2FHUGOBOSS-MENFRAGRANCEBOSSBOTTLEDBEYONDEAUDEPARFUM100ML-CDS24802130-12.webp&w=1080&q=75', 0, '8357223767340');

INSERT INTO Perfume VALUES
('CH-21520', 'EAU DE PARFUM', 4.11, 1855, 'Christian Dior', 'Masculine', '6703227867003'),
('BD-73441', 'EAU DE PARFUM', '4.22', 8445, 'BDK Parfums', 'Unisex', '5865518889480'),
('EM-82544', 'PARFUM', '4.27', 2966, 'Emporio Armani', 'Masculine', '5655062908095'),
('GI-47382', 'PARFUM', '4.41', 6404, 'GIORGIO ARMANI', 'Masculine', '4870270827970'),
('HU-67488', 'EAU DE PARFUM', '3.94', 1273, 'Hugo Boss', 'Masculine', '8357223767340'),
('PA-81909', 'EAU DE PARFUM', '4.35', 7354, 'Paradise Perfumes and Gems', 'Masculine', '9784839464339'),
('PR-48482', 'EAU DE TOILETTE', '4.18', 2695, 'Prada', 'Masculine', '3886177383183'),
('TO-63032', 'EAU DE PARFUM', '4.13', 3056, 'Tom Ford', 'Unisex', '1738478326521'),
('VA-15641', 'EAU DE PARFUM', '3.73', 1807, 'Valentino', 'Feminine', '4846676644071'),
('YV-12490', 'EAU DE PARFUM', '4.14', 820, 'Yves Saint Laurent', 'Unisex', '9439369400279'),
('YV-99733', 'EAU DE PARFUM', '4.31', 2340, 'Yves Saint Laurent', 'Masculine', '6644093067615');

INSERT INTO Admin_login VALUES
('L00001', 'thung123', '123456', 'Admin', '000035'),
('L00002', 'phukao123', '123456', 'Admin', '000070'),
('L00003', 'view123', '123456', 'Admin', '000150'),
('L00004', 'tigger123', '123456', 'Admin', '000154'),
('L00005', 'note123', '123456', 'Admin', '000209');

INSERT INTO Product_Variant (product_id, volume, price, stock) VALUES
('6703227867003', 100, 5720.00, 100),
('4870270827970', 75, '5568.00', 100),
('5655062908095', 50, '4400.00', 100),
('5655062908095', 100, '5800.00', 100),
('4846676644071', 100, '7300.00', 100),
('4846676644071', 50, '5300.00', 100),
('5865518889480', 100, '7600.00', 100),
('9784839464339', 50, '4200.00', 100),
('3886177383183', 100, '4950.00', 100),
('1738478326521', 50, '6435.00', 100),
('9439369400279', 125, '10350.00', 100),
('6644093067615', 100, '6290.00', 100),
('8357223767340', 100, '4667.00', 100);