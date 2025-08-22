-- OBJECT: languages
-- ISSUE: add language translation support

CREATE TABLE IF NOT EXISTS core.languages (
    language_code text PRIMARY KEY,
    language_name text NOT NULL
);

-- Translation table for categories
CREATE TABLE IF NOT EXISTS core.translate (
    table_name text NOT NULL,
    column_name text NOT NULL,
    language_code text NOT NULL,
    string text NOT NULL,
    translation text,
    PRIMARY KEY (table_name, column_name, language_code, string),
    FOREIGN KEY (language_code) REFERENCES core.languages(language_code));

INSERT INTO core.languages (language_code, language_name) VALUES
-- Major world languages
('en', 'English'),
('es', 'Spanish'),
('fr', 'French'),
('de', 'German'),
('it', 'Italian'),
('pt', 'Portuguese'),
('ru', 'Russian'),
('zh', 'Chinese'),
('ja', 'Japanese'),
('ko', 'Korean'),
('ar', 'Arabic'),
('hi', 'Hindi'),
('bn', 'Bengali'),
('pa', 'Punjabi'),

-- European languages
('nl', 'Dutch'),
('sv', 'Swedish'),
('fi', 'Finnish'),
('da', 'Danish'),
('no', 'Norwegian'),
('pl', 'Polish'),
('uk', 'Ukrainian'),
('cs', 'Czech'),
('hu', 'Hungarian'),
('ro', 'Romanian'),
('el', 'Greek'),
('tr', 'Turkish'),

-- Other important languages
('fa', 'Persian'),
('ur', 'Urdu'),
('th', 'Thai'),
('vi', 'Vietnamese'),
('id', 'Indonesian'),
('ms', 'Malay'),
('he', 'Hebrew'),
('tl', 'Filipino'),
('sw', 'Swahili'),

-- Regional languages
('ca', 'Catalan'),
('eu', 'Basque'),
('ga', 'Irish'),
('cy', 'Welsh'),
('gd', 'Scottish Gaelic'),
('hr', 'Croatian'),
('sr', 'Serbian'),
('sk', 'Slovak'),
('sl', 'Slovenian'),
('lv', 'Latvian'),
('lt', 'Lithuanian'),
('et', 'Estonian'),
('bg', 'Bulgarian'),

-- Asian languages
('ta', 'Tamil'),
('te', 'Telugu'),
('kn', 'Kannada'),
('ml', 'Malayalam'),
('mr', 'Marathi'),
('gu', 'Gujarati'),
('or', 'Odia'),
('as', 'Assamese'),
('ne', 'Nepali'),
('si', 'Sinhala'),
('my', 'Burmese'),
('km', 'Khmer'),
('lo', 'Lao'),
('mn', 'Mongolian'),

-- African languages
('am', 'Amharic'),
('ha', 'Hausa'),
('ig', 'Igbo'),
('yo', 'Yoruba'),
('zu', 'Zulu'),
('xh', 'Xhosa'),
('st', 'Southern Sotho'),
('sn', 'Shona'),
('rw', 'Kinyarwanda'),
('so', 'Somali');

INSERT INTO core.translate (table_name, column_name, language_code, string) 
SELECT 'property_desc', 'property_pretty_name', 'es', property_pretty_name FROM core.property_desc
    UNION
SELECT 'category_desc', 'category_desc_id', 'es', category_desc_id FROM core.category_desc
    UNION
SELECT 'property_phys_chem', 'property_phys_chem_id', 'es', property_phys_chem_id FROM core.property_phys_chem;
