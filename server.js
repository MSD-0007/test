// Import required modules
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Initialize the app
const app = express();
const PORT = process.env.PORT || 5000;
const SECRET_KEY = 'your_secret_key'; // Replace with a secure key in production

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/tourismDB', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', () => {
    console.log('Connected to MongoDB');
});

// Define schemas and models
const userSchema = new mongoose.Schema({
    username: String,
    password: String,
});

const destinationSchema = new mongoose.Schema({
    name: String,
    description: String,
    imageUrl: String,
});

const feedbackSchema = new mongoose.Schema({
    username: String,
    feedback: String,
});

const User = mongoose.model('User', userSchema);
const Destination = mongoose.model('Destination', destinationSchema);
const Feedback = mongoose.model('Feedback', feedbackSchema);

// Routes

// Register a new user
app.post('/register', async (req, res) => {
    const { username, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        const newUser = new User({ username, password: hashedPassword });
        await newUser.save();
        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        res.status(500).json({ error: 'Error registering user' });
    }
});

// User login
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        const user = await User.findOne({ username });
        if (!user) return res.status(404).json({ error: 'User not found' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });

        const token = jwt.sign({ username }, SECRET_KEY, { expiresIn: '1h' });
        res.status(200).json({ token });
    } catch (err) {
        res.status(500).json({ error: 'Error logging in' });
    }
});

// Add a destination
app.post('/destinations', async (req, res) => {
    const { name, description, imageUrl } = req.body;

    try {
        const newDestination = new Destination({ name, description, imageUrl });
        await newDestination.save();
        res.status(201).json({ message: 'Destination added successfully' });
    } catch (err) {
        res.status(500).json({ error: 'Error adding destination' });
    }
});

// Get all destinations
app.get('/destinations', async (req, res) => {
    try {
        const destinations = await Destination.find();
        res.status(200).json(destinations);
    } catch (err) {
        res.status(500).json({ error: 'Error fetching destinations' });
    }
});

// Submit feedback
app.post('/feedback', async (req, res) => {
    const { username, feedback } = req.body;

    try {
        const newFeedback = new Feedback({ username, feedback });
        await newFeedback.save();
        res.status(201).json({ message: 'Feedback submitted successfully' });
    } catch (err) {
        res.status(500).json({ error: 'Error submitting feedback' });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
