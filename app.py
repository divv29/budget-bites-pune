from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import bcrypt
import os

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'budget-bites-pune-secret-2024')

# ── Database Configuration ──────────────────────────────────────
# Update these credentials to match your PostgreSQL setup
DB_USER = os.environ.get('DB_USER', 'postgres')
DB_PASS = os.environ.get('DB_PASS', 'postgres')
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_PORT = os.environ.get('DB_PORT', '5432')
DB_NAME = os.environ.get('DB_NAME', 'budget_bites_pune')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql+psycopg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# ── Models ──────────────────────────────────────────────────────

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Restaurant(db.Model):
    __tablename__ = 'restaurants'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), nullable=False)
    description = db.Column(db.Text)
    location = db.Column(db.String(200), nullable=False)
    area = db.Column(db.String(100), nullable=False)
    cuisine = db.Column(db.String(100), nullable=False)
    rating = db.Column(db.Numeric(2, 1), default=4.0)
    avg_price_for_two = db.Column(db.Integer, nullable=False)
    image_url = db.Column(db.String(500))
    is_featured = db.Column(db.Boolean, default=False)
    is_active = db.Column(db.Boolean, default=True)
    opening_hours = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    menu_items = db.relationship('MenuItem', backref='restaurant', lazy=True, cascade='all, delete-orphan')

class MenuItem(db.Model):
    __tablename__ = 'menu_items'
    id = db.Column(db.Integer, primary_key=True)
    restaurant_id = db.Column(db.Integer, db.ForeignKey('restaurants.id'), nullable=False)
    name = db.Column(db.String(150), nullable=False)
    description = db.Column(db.Text)
    price = db.Column(db.Integer, nullable=False)
    category = db.Column(db.String(50), nullable=False)
    is_veg = db.Column(db.Boolean, default=True)
    is_popular = db.Column(db.Boolean, default=False)

class Review(db.Model):
    __tablename__ = 'reviews'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    restaurant_id = db.Column(db.Integer, db.ForeignKey('restaurants.id'))
    rating = db.Column(db.Integer)
    comment = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    user = db.relationship('User', backref='reviews')
    restaurant = db.relationship('Restaurant', backref='reviews')

# ── Helpers ─────────────────────────────────────────────────────

def current_user():
    if 'user_id' in session:
        return User.query.get(session['user_id'])
    return None

def login_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please log in to continue.', 'error')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        user = current_user()
        if not user or not user.is_admin:
            flash('Admin access required.', 'error')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated

def price_label(price):
    if price <= 300:
        return '₹ Budget'
    elif price <= 600:
        return '₹₹ Moderate'
    elif price <= 1000:
        return '₹₹₹ Premium'
    else:
        return '₹₹₹₹ Fine Dining'

# ── Context Processor ────────────────────────────────────────────
@app.context_processor
def inject_globals():
    return dict(current_user=current_user(), price_label=price_label)

# ── Routes ───────────────────────────────────────────────────────

@app.route('/')
def index():
    featured = Restaurant.query.filter_by(is_featured=True, is_active=True).limit(6).all()
    top_rated = Restaurant.query.filter_by(is_active=True).order_by(Restaurant.rating.desc()).limit(8).all()
    areas = db.session.query(Restaurant.area).distinct().all()
    cuisines = db.session.query(Restaurant.cuisine).distinct().all()
    return render_template('index.html', featured=featured, top_rated=top_rated,
                           areas=[a[0] for a in areas], cuisines=[c[0] for c in cuisines])

@app.route('/restaurants')
def restaurants():
    query = Restaurant.query.filter_by(is_active=True)

    search = request.args.get('search', '').strip()
    area = request.args.get('area', '')
    cuisine = request.args.get('cuisine', '')
    price_min = request.args.get('price_min', type=int)
    price_max = request.args.get('price_max', type=int)
    min_rating = request.args.get('rating', type=float)
    sort = request.args.get('sort', 'rating')

    if search:
        query = query.filter(
            db.or_(
                Restaurant.name.ilike(f'%{search}%'),
                Restaurant.cuisine.ilike(f'%{search}%'),
                Restaurant.area.ilike(f'%{search}%'),
                Restaurant.location.ilike(f'%{search}%')
            )
        )
    if area:
        query = query.filter_by(area=area)
    if cuisine:
        query = query.filter(Restaurant.cuisine.ilike(f'%{cuisine}%'))
    if price_min:
        query = query.filter(Restaurant.avg_price_for_two >= price_min)
    if price_max:
        query = query.filter(Restaurant.avg_price_for_two <= price_max)
    if min_rating:
        query = query.filter(Restaurant.rating >= min_rating)

    if sort == 'price_asc':
        query = query.order_by(Restaurant.avg_price_for_two.asc())
    elif sort == 'price_desc':
        query = query.order_by(Restaurant.avg_price_for_two.desc())
    else:
        query = query.order_by(Restaurant.rating.desc())

    all_restaurants = query.all()
    areas = db.session.query(Restaurant.area).distinct().all()
    cuisines = db.session.query(Restaurant.cuisine).distinct().all()

    return render_template('restaurants.html',
                           restaurants=all_restaurants,
                           areas=[a[0] for a in areas],
                           cuisines=[c[0] for c in cuisines],
                           search=search, selected_area=area,
                           selected_cuisine=cuisine)

@app.route('/restaurant/<int:restaurant_id>')
def restaurant_detail(restaurant_id):
    restaurant = Restaurant.query.get_or_404(restaurant_id)
    menu_by_category = {}
    for item in restaurant.menu_items:
        menu_by_category.setdefault(item.category, []).append(item)
    reviews = Review.query.filter_by(restaurant_id=restaurant_id).order_by(Review.created_at.desc()).limit(5).all()
    related = Restaurant.query.filter(
        Restaurant.area == restaurant.area,
        Restaurant.id != restaurant.id,
        Restaurant.is_active == True
    ).limit(3).all()
    return render_template('restaurant.html', restaurant=restaurant,
                           menu_by_category=menu_by_category,
                           reviews=reviews, related=related,
                           price_label=price_label(restaurant.avg_price_for_two))

@app.route('/restaurant/<int:restaurant_id>/review', methods=['POST'])
@login_required
def add_review(restaurant_id):
    rating = request.form.get('rating', type=int)
    comment = request.form.get('comment', '').strip()
    if rating and 1 <= rating <= 5:
        review = Review(user_id=session['user_id'], restaurant_id=restaurant_id,
                        rating=rating, comment=comment)
        db.session.add(review)
        # Update restaurant avg rating
        reviews = Review.query.filter_by(restaurant_id=restaurant_id).all()
        avg = sum(r.rating for r in reviews) / len(reviews)
        restaurant = Restaurant.query.get(restaurant_id)
        restaurant.rating = round(avg, 1)
        db.session.commit()
        flash('Review submitted!', 'success')
    return redirect(url_for('restaurant_detail', restaurant_id=restaurant_id))

# ── API ─────────────────────────────────────────────────────────

@app.route('/api/search')
def api_search():
    q = request.args.get('q', '').strip()
    if len(q) < 2:
        return jsonify([])
    results = Restaurant.query.filter(
        db.or_(
            Restaurant.name.ilike(f'%{q}%'),
            Restaurant.cuisine.ilike(f'%{q}%'),
            Restaurant.area.ilike(f'%{q}%')
        ),
        Restaurant.is_active == True
    ).limit(6).all()
    return jsonify([{
        'id': r.id, 'name': r.name, 'area': r.area,
        'cuisine': r.cuisine, 'rating': float(r.rating),
        'price': r.avg_price_for_two
    } for r in results])

# ── Auth Routes ─────────────────────────────────────────────────

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if 'user_id' in session:
        return redirect(url_for('index'))
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')
        confirm = request.form.get('confirm_password', '')

        errors = []
        if len(username) < 3:
            errors.append('Username must be at least 3 characters.')
        if '@' not in email:
            errors.append('Enter a valid email address.')
        if len(password) < 6:
            errors.append('Password must be at least 6 characters.')
        if password != confirm:
            errors.append('Passwords do not match.')
        if User.query.filter_by(username=username).first():
            errors.append('Username already taken.')
        if User.query.filter_by(email=email).first():
            errors.append('Email already registered.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template('signup.html', username=username, email=email)

        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        user = User(username=username, email=email, password_hash=hashed)
        db.session.add(user)
        db.session.commit()
        session['user_id'] = user.id
        flash(f'Welcome to Budget Bites, {username}!', 'success')
        return redirect(url_for('index'))

    return render_template('signup.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        return redirect(url_for('index'))
    if request.method == 'POST':
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')
        user = User.query.filter_by(email=email).first()

        if user and bcrypt.checkpw(password.encode(), user.password_hash.encode()):
            session['user_id'] = user.id
            flash(f'Welcome back, {user.username}!', 'success')
            return redirect(request.args.get('next') or url_for('index'))
        else:
            flash('Invalid email or password.', 'error')

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    flash('Logged out successfully.', 'success')
    return redirect(url_for('index'))

@app.route('/profile')
@login_required
def profile():
    user = current_user()
    my_reviews = Review.query.filter_by(user_id=user.id).order_by(Review.created_at.desc()).all()
    return render_template('profile.html', user=user, reviews=my_reviews)

# ── Admin Routes ─────────────────────────────────────────────────

@app.route('/admin')
@admin_required
def admin_dashboard():
    restaurants = Restaurant.query.order_by(Restaurant.created_at.desc()).all()
    users_count = User.query.count()
    return render_template('admin.html', restaurants=restaurants, users_count=users_count)

@app.route('/admin/restaurant/add', methods=['GET', 'POST'])
@admin_required
def admin_add_restaurant():
    if request.method == 'POST':
        r = Restaurant(
            name=request.form['name'],
            description=request.form.get('description', ''),
            location=request.form['location'],
            area=request.form['area'],
            cuisine=request.form['cuisine'],
            rating=float(request.form.get('rating', 4.0)),
            avg_price_for_two=int(request.form['avg_price_for_two']),
            image_url=request.form.get('image_url', ''),
            is_featured='is_featured' in request.form,
            opening_hours=request.form.get('opening_hours', ''),
            phone=request.form.get('phone', '')
        )
        db.session.add(r)
        db.session.commit()
        flash('Restaurant added!', 'success')
        return redirect(url_for('admin_dashboard'))
    return render_template('admin_form.html', restaurant=None, action='Add')

@app.route('/admin/restaurant/<int:rid>/edit', methods=['GET', 'POST'])
@admin_required
def admin_edit_restaurant(rid):
    restaurant = Restaurant.query.get_or_404(rid)
    if request.method == 'POST':
        restaurant.name = request.form['name']
        restaurant.description = request.form.get('description', '')
        restaurant.location = request.form['location']
        restaurant.area = request.form['area']
        restaurant.cuisine = request.form['cuisine']
        restaurant.rating = float(request.form.get('rating', 4.0))
        restaurant.avg_price_for_two = int(request.form['avg_price_for_two'])
        restaurant.image_url = request.form.get('image_url', '')
        restaurant.is_featured = 'is_featured' in request.form
        restaurant.opening_hours = request.form.get('opening_hours', '')
        restaurant.phone = request.form.get('phone', '')
        db.session.commit()
        flash('Restaurant updated!', 'success')
        return redirect(url_for('admin_dashboard'))
    return render_template('admin_form.html', restaurant=restaurant, action='Edit')

@app.route('/admin/restaurant/<int:rid>/delete', methods=['POST'])
@admin_required
def admin_delete_restaurant(rid):
    restaurant = Restaurant.query.get_or_404(rid)
    db.session.delete(restaurant)
    db.session.commit()
    flash('Restaurant deleted.', 'success')
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/restaurant/<int:rid>/menu/add', methods=['POST'])
@admin_required
def admin_add_menu_item(rid):
    item = MenuItem(
        restaurant_id=rid,
        name=request.form['name'],
        description=request.form.get('description', ''),
        price=int(request.form['price']),
        category=request.form['category'],
        is_veg='is_veg' in request.form,
        is_popular='is_popular' in request.form
    )
    db.session.add(item)
    db.session.commit()
    flash('Menu item added!', 'success')
    return redirect(url_for('restaurant_detail', restaurant_id=rid))

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, port=5000)
