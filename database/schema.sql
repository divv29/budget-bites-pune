-- Budget Bites Pune - PostgreSQL Schema
-- Run this file to initialize the database

-- Drop existing tables
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Restaurants table
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    location VARCHAR(200) NOT NULL,
    area VARCHAR(100) NOT NULL,
    cuisine VARCHAR(100) NOT NULL,
    rating DECIMAL(2,1) DEFAULT 4.0,
    avg_price_for_two INTEGER NOT NULL,
    image_url VARCHAR(500),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    opening_hours VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Menu items table
CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price INTEGER NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('Starters', 'Main Course', 'Desserts', 'Drinks', 'Snacks', 'Breads')),
    is_veg BOOLEAN DEFAULT TRUE,
    is_popular BOOLEAN DEFAULT FALSE
);

-- Reviews table
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    restaurant_id INTEGER REFERENCES restaurants(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Admin user (password: admin123)
INSERT INTO users (username, email, password_hash, is_admin) VALUES
('admin', 'admin@budgetbites.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMqJqhg5NL2l.UWp2qTuVkc2WO', TRUE);

-- Restaurants
INSERT INTO restaurants (name, description, location, area, cuisine, rating, avg_price_for_two, image_url, is_featured, opening_hours, phone) VALUES

('Vaishali', 'An iconic Pune institution since 1958, Vaishali is beloved for its South Indian breakfast and snacks. The place is always buzzing with energy and serves the best idli-vada in the city.', 'FC Road, Deccan Gymkhana', 'Deccan', 'South Indian', 4.5, 300, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=800', TRUE, '7:00 AM - 11:00 PM', '020-25539641'),

('Goodluck Cafe', 'A Pune landmark since 1935, Goodluck Cafe is famous for its Irani chai, bun maska, and keema pav. The vintage ambience and old-world charm make it a must-visit.', 'Opposite Jehangir Hospital, Camp', 'Camp', 'Irani, Continental', 4.3, 250, 'https://images.unsplash.com/photo-1514190051997-0f6f39ca5cde?w=800', TRUE, '7:30 AM - 11:30 PM', '020-26135752'),

('Burger Camp', 'Pune''s favourite gourmet burger joint offering creative, loaded burgers at budget-friendly prices. Popular among college students for its generous portions and bold flavours.', 'Baner Road, Baner', 'Baner', 'American, Fast Food', 4.2, 450, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800', FALSE, '11:00 AM - 11:30 PM', '9876543210'),

('Le Plaisir', 'An elegant French-Continental restaurant with a beautiful garden setting. Known for its wood-fired pizza, pasta, and continental entrees, perfect for a special occasion.', 'Koregaon Park, KP', 'Koregaon Park', 'Continental, French', 4.6, 1200, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800', TRUE, '12:00 PM - 11:00 PM', '020-26150000'),

('Savya Rasa', 'An upscale restaurant celebrating the culinary heritage of Karnataka and Tamil Nadu. Features an extensive thali and regional specialties prepared with authentic recipes.', 'Kalyani Nagar', 'Kalyani Nagar', 'South Indian, Karnataka', 4.4, 800, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800', TRUE, '12:00 PM - 3:30 PM, 7:00 PM - 11:00 PM', '020-67006700'),

('Terttulia', 'A cozy cafe with a warm European vibe serving artisanal coffee, salads, sandwiches, and freshly baked pastries. The perfect spot to work or catch up with friends.', 'Koregaon Park Lane 5', 'Koregaon Park', 'Cafe, European', 4.4, 600, 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800', FALSE, '8:00 AM - 10:30 PM', '9890123456'),

('Cafe Peter', 'One of Pune''s oldest Continental restaurants dating back to 1942. Famous for its sizzlers, rolls, and classic Pune-style western dishes loved by generations.', 'Moledina Road, Camp', 'Camp', 'Continental, Sizzlers', 4.1, 500, 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=800', FALSE, '11:00 AM - 11:00 PM', '020-26126787'),

('Barbeque Nation', 'The ultimate live grill experience where you become your own chef! Unlimited starters grilled at your table, followed by a lavish buffet spread. Perfect for groups.', 'Aundh Road, Aundh', 'Aundh', 'Barbeque, Multi-cuisine', 4.3, 1100, 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=800', TRUE, '12:00 PM - 3:30 PM, 6:30 PM - 11:00 PM', '1800-120-2180'),

('Irani Cafe', 'An authentic Irani eatery preserving the culinary traditions brought to Pune by Persian immigrants. The chai, bun maska, and egg burji are legendary.', 'MG Road, Camp', 'Camp', 'Irani, Breakfast', 4.0, 200, 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800', FALSE, '7:00 AM - 10:00 PM', '020-26120456'),

('FC Road Food Street', 'A vibrant street food hub along Fergusson College Road offering everything from misal pav and vada pav to chaat, pav bhaji, and rolls. The heartbeat of student life in Pune.', 'Fergusson College Road, Deccan', 'Deccan', 'Street Food, Indian', 4.2, 150, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800', FALSE, '10:00 AM - 12:00 AM', 'N/A'),

('The Flour Works', 'A much-loved all-day cafe in Viman Nagar with artisan breads, hearty breakfasts, and globally-inspired plates. Known for its relaxed vibe and excellent brunch options.', 'North Main Road, Viman Nagar', 'Viman Nagar', 'Cafe, World Cuisine', 4.5, 700, 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800', FALSE, '8:00 AM - 10:30 PM', '9765432109'),

('Malaka Spice', 'A celebrated pan-Asian restaurant known for its vibrant South-East Asian flavours. The outdoor garden seating, Thai curries, and sushi platters are crowd favourites.', 'Koregaon Park Lane 5', 'Koregaon Park', 'Asian, Thai, Japanese', 4.5, 900, 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=800', TRUE, '12:00 PM - 11:00 PM', '020-26153421'),

('Shabree', 'A legendary Maharashtrian thali restaurant serving authentic home-style food. The unlimited thali with solkadhi, bhakri, and seasonal vegetables is the highlight.', 'Karve Road, Erandwane', 'Erandwane', 'Maharashtrian', 4.3, 350, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800', FALSE, '11:00 AM - 3:30 PM, 7:00 PM - 10:30 PM', '020-25435000'),

('Wadeshwar', 'Famous for its traditional Pune-style breakfasts and snacks. The Sabudana khichdi, poha, and batata vada are freshly prepared every morning and loved by locals.', 'FC Road, Shivajinagar', 'Shivajinagar', 'Maharashtrian, Breakfast', 4.0, 200, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=800', FALSE, '7:00 AM - 2:00 PM, 5:00 PM - 9:00 PM', '020-25539000'),

('The Sassy Spoon', 'A chic modern cafe known for its inventive menu, beautiful plating, and cosy interiors. Popular for brunch dates, its eggs benedict and smoothie bowls are Instagram-worthy.', 'North Main Road, Koregaon Park', 'Koregaon Park', 'Continental, Cafe', 4.4, 800, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800', FALSE, '9:00 AM - 11:00 PM', '9890098900'),

('Cafe Papaya', 'A budget-friendly cafe in Baner offering fresh juices, salads, sandwiches, and healthy bowls. A favourite among IT professionals for its quick service and healthy options.', 'Baner Gaon Road, Baner', 'Baner', 'Cafe, Healthy', 3.9, 400, 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800', FALSE, '9:00 AM - 10:30 PM', '9765000123'),

('Spice Kitchen', 'A popular North Indian restaurant in Wakad serving robust curries, tandoori platters, and fresh rotis. The dal makhani and butter chicken are consistently outstanding.', 'Wakad Road, Wakad', 'Wakad', 'North Indian', 4.1, 550, 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800', FALSE, '11:30 AM - 11:00 PM', '9823456789'),

('Seasons', 'A beloved bakery and cafe chain known for its fresh-baked goods, pastries, and quick snacks. The warm ambience and consistent quality keep patrons coming back daily.', 'JM Road, Shivajinagar', 'Shivajinagar', 'Bakery, Cafe', 4.0, 300, 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=800', FALSE, '8:00 AM - 10:00 PM', '020-25521234');

-- Menu items for Vaishali (id=1)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(1, 'Masala Dosa', 'Crispy rice crepe filled with spiced potato masala, served with sambar and three chutneys', 120, 'Main Course', TRUE, TRUE),
(1, 'Idli (2 pieces)', 'Soft steamed rice cakes served with sambar and coconut chutney', 80, 'Starters', TRUE, TRUE),
(1, 'Medu Vada', 'Crispy lentil fritters served with sambar and coconut chutney', 90, 'Starters', TRUE, FALSE),
(1, 'Set Dosa', 'Soft, spongy mini dosas served in a set of 3 with chutney', 110, 'Main Course', TRUE, FALSE),
(1, 'Upma', 'Savoury semolina porridge tempered with mustard seeds and curry leaves', 85, 'Main Course', TRUE, FALSE),
(1, 'Filter Coffee', 'Authentic South Indian filter coffee with frothy milk', 45, 'Drinks', TRUE, TRUE),
(1, 'Buttermilk', 'Chilled spiced buttermilk garnished with coriander', 40, 'Drinks', TRUE, FALSE),
(1, 'Rava Idli', 'Steamed semolina cakes with cashews and spices', 95, 'Starters', TRUE, FALSE);

-- Menu items for Goodluck Cafe (id=2)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(2, 'Bun Maska', 'Soft bun generously buttered, served with Irani chai', 50, 'Snacks', TRUE, TRUE),
(2, 'Keema Pav', 'Spiced mutton mince served with soft pav buns', 150, 'Main Course', FALSE, TRUE),
(2, 'Irani Chai', 'Rich, creamy tea brewed in the traditional Persian style', 30, 'Drinks', TRUE, TRUE),
(2, 'Egg Bhurji Pav', 'Scrambled eggs cooked with onions and spices, served with pav', 120, 'Main Course', FALSE, FALSE),
(2, 'Mava Cake', 'Traditional Irani-style sweet cake made with mava', 60, 'Desserts', TRUE, FALSE),
(2, 'Osmania Biscuit', 'Classic Persian-style tea biscuit, perfect with chai', 20, 'Snacks', TRUE, TRUE),
(2, 'Cold Coffee', 'Chilled coffee with milk and sugar', 80, 'Drinks', TRUE, FALSE);

-- Menu items for Burger Camp (id=3)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(3, 'Camp Classic Burger', 'Double patty smash burger with cheddar, pickles, and house sauce', 249, 'Main Course', FALSE, TRUE),
(3, 'Veggie Smash', 'Crispy veggie patty with lettuce, tomato, and sriracha mayo', 199, 'Main Course', TRUE, TRUE),
(3, 'Loaded Fries', 'Crispy fries topped with cheese sauce, jalapeños, and ranch', 149, 'Starters', TRUE, FALSE),
(3, 'Chicken Wings', '6 pieces of crispy wings in choice of sauce: BBQ, Buffalo, or Honey Garlic', 229, 'Starters', FALSE, TRUE),
(3, 'Nutella Milkshake', 'Thick milkshake blended with Nutella and topped with cream', 149, 'Drinks', TRUE, FALSE),
(3, 'Truffle Burger', 'Gourmet beef patty with truffle aioli, arugula, and aged cheddar', 299, 'Main Course', FALSE, FALSE),
(3, 'Oreo Blast', 'Creamy milkshake blended with Oreo cookies', 139, 'Drinks', TRUE, FALSE);

-- Menu items for Le Plaisir (id=4)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(4, 'Wood-fired Margherita', 'Classic wood-fired pizza with San Marzano tomatoes and buffalo mozzarella', 450, 'Main Course', TRUE, TRUE),
(4, 'Truffle Arancini', 'Crispy risotto balls with truffle and parmesan cream', 380, 'Starters', TRUE, FALSE),
(4, 'Beef Tenderloin', 'Pan-seared tenderloin with mushroom jus and roasted vegetables', 950, 'Main Course', FALSE, TRUE),
(4, 'Penne Arrabbiata', 'Classic spicy tomato pasta with fresh basil and parmesan', 380, 'Main Course', TRUE, FALSE),
(4, 'Crème Brûlée', 'Classic French vanilla custard with a caramelised sugar crust', 280, 'Desserts', TRUE, TRUE),
(4, 'French Onion Soup', 'Rich slow-cooked onion broth with gruyère crouton', 320, 'Starters', TRUE, FALSE),
(4, 'House Red Wine (Glass)', 'Curated red wine selection', 450, 'Drinks', TRUE, FALSE);

-- Menu items for Savya Rasa (id=5)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(5, 'Karnataka Thali', 'Complete authentic Karnataka meal with rice, rasam, 4 curries, papad, and dessert', 550, 'Main Course', TRUE, TRUE),
(5, 'Pesarattu', 'Green moong dal crepes served with ginger chutney and upma', 220, 'Starters', TRUE, FALSE),
(5, 'Coorgi Pork Curry', 'Slow-cooked pork in traditional Kodava spice blend', 420, 'Main Course', FALSE, TRUE),
(5, 'Bisibelebath', 'Traditional Karnataka dish of lentils, rice, and vegetables in spiced tamarind', 280, 'Main Course', TRUE, FALSE),
(5, 'Payasam', 'Traditional South Indian sweet kheer with vermicelli', 120, 'Desserts', TRUE, TRUE),
(5, 'Filter Coffee', 'Traditional South Indian decoction coffee', 60, 'Drinks', TRUE, TRUE),
(5, 'Akki Roti', 'Rice flour flatbread with onions, coriander, and chillies', 180, 'Breads', TRUE, FALSE);

-- Menu items for Barbeque Nation (id=8)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(8, 'Veg BBQ Buffet', 'Unlimited live grill starters + buffet with veg options only', 799, 'Main Course', TRUE, FALSE),
(8, 'Non-Veg BBQ Buffet', 'Unlimited live grill starters + full buffet spread with all options', 999, 'Main Course', FALSE, TRUE),
(8, 'Cajun Spice Potatoes', 'Live grill potatoes with smoky cajun seasoning', 0, 'Starters', TRUE, TRUE),
(8, 'Peri Peri Chicken', 'Juicy chicken skewers marinated in African peri-peri sauce', 0, 'Starters', FALSE, TRUE),
(8, 'Kulfi Falooda', 'Creamy kulfi with falooda noodles and rose syrup', 0, 'Desserts', TRUE, FALSE);

-- Menu items for FC Road Food Street (id=10)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(10, 'Vada Pav', 'Mumbai-style spiced potato fritter in a soft bun with chutneys', 20, 'Snacks', TRUE, TRUE),
(10, 'Misal Pav', 'Spicy sprouted moth bean curry topped with farsan and served with pav', 60, 'Main Course', TRUE, TRUE),
(10, 'Pav Bhaji', 'Spiced vegetable mash served with buttered pav and onions', 80, 'Main Course', TRUE, TRUE),
(10, 'Ragda Pattice', 'Crispy potato patties on white pea curry with chutneys and sev', 70, 'Snacks', TRUE, FALSE),
(10, 'Sugarcane Juice', 'Fresh cold pressed sugarcane juice with lemon and ginger', 30, 'Drinks', TRUE, TRUE),
(10, 'Pani Puri (6 pieces)', 'Hollow crispy puris filled with spiced tangy water and potato', 40, 'Starters', TRUE, FALSE);

-- Menu items for Malaka Spice (id=12)
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_veg, is_popular) VALUES
(12, 'Green Thai Curry', 'Aromatic coconut milk curry with Thai basil, tofu, and vegetables', 480, 'Main Course', TRUE, TRUE),
(12, 'Chicken Pad Thai', 'Classic Thai stir-fried rice noodles with egg, peanuts, and lime', 420, 'Main Course', FALSE, TRUE),
(12, 'Edamame', 'Steamed edamame pods with sea salt and sesame oil', 220, 'Starters', TRUE, FALSE),
(12, 'Mango Sticky Rice', 'Traditional Thai dessert with sweet glutinous rice and fresh mango', 280, 'Desserts', TRUE, TRUE),
(12, 'Lemongrass Mojito', 'Refreshing mocktail with lemongrass, mint, and lime', 180, 'Drinks', TRUE, FALSE),
(12, 'Dim Sum Platter', 'Assorted steamed dumplings with soy dipping sauce', 380, 'Starters', FALSE, FALSE);

COMMIT;
