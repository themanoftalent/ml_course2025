/*
  # Seed Sample Data for SoftAI Academy

  ## Overview
  This migration seeds the database with sample content to demonstrate the platform:
  - Tags for categorization
  - Sample courses with modules and lessons
  - Sample quizzes with questions
  - Sample blog posts
  - Sample resources

  ## Content Structure
  1. Tags (topics, skills, frameworks)
  2. Beginner Course: "Introduction to Machine Learning"
     - Module 1: ML Basics (2 lessons + quiz)
     - Module 2: Data Structures (2 lessons)
  3. Intermediate Course: "Deep Learning Fundamentals"
     - Module 1: Neural Networks (1 lesson)
  4. Blog Posts (2 published articles)
  5. Resources (3 external resources)
*/

-- =====================================================
-- 1. CREATE TAGS
-- =====================================================

INSERT INTO tags (id, name, slug, tag_type) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Machine Learning', 'machine-learning', 'topic'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Deep Learning', 'deep-learning', 'topic'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Natural Language Processing', 'nlp', 'topic'),
  ('550e8400-e29b-41d4-a716-446655440004', 'Computer Vision', 'computer-vision', 'topic'),
  ('550e8400-e29b-41d4-a716-446655440005', 'Python', 'python', 'skill'),
  ('550e8400-e29b-41d4-a716-446655440006', 'Data Analysis', 'data-analysis', 'skill'),
  ('550e8400-e29b-41d4-a716-446655440007', 'Model Training', 'model-training', 'skill'),
  ('550e8400-e29b-41d4-a716-446655440008', 'TensorFlow', 'tensorflow', 'framework'),
  ('550e8400-e29b-41d4-a716-446655440009', 'PyTorch', 'pytorch', 'framework'),
  ('550e8400-e29b-41d4-a716-446655440010', 'Scikit-learn', 'scikit-learn', 'framework')
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- 2. CREATE BEGINNER COURSE
-- =====================================================

INSERT INTO courses (id, title, slug, summary, description, level, duration_minutes, published) VALUES
  (
    '650e8400-e29b-41d4-a716-446655440001',
    'Introduction to Machine Learning',
    'introduction-to-machine-learning',
    'Learn the fundamentals of machine learning, from basic concepts to practical implementations.',
    'This comprehensive course covers the essential concepts of machine learning. You will learn about supervised and unsupervised learning, data preprocessing, model evaluation, and more. Perfect for beginners with basic Python knowledge.',
    'beginner',
    180,
    true
  )
ON CONFLICT (slug) DO NOTHING;

INSERT INTO course_tags (course_id, tag_id) VALUES
  ('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
  ('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005'),
  ('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440010')
ON CONFLICT DO NOTHING;

-- Module 1: Introduction to ML
INSERT INTO modules (id, course_id, title, "order") VALUES
  ('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', 'Introduction to ML', 1)
ON CONFLICT DO NOTHING;

-- Quiz for Module 1
INSERT INTO quizzes (id, title, time_limit_minutes, pass_score_percent, course_id) VALUES
  ('950e8400-e29b-41d4-a716-446655440001', 'ML Basics Quiz', 15, 70, '650e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Lessons for Module 1
INSERT INTO lessons (id, module_id, course_id, title, slug, content, duration_minutes, "order", published, quiz_id) VALUES
  (
    '850e8400-e29b-41d4-a716-446655440001',
    '750e8400-e29b-41d4-a716-446655440001',
    '650e8400-e29b-41d4-a716-446655440001',
    'What is Machine Learning?',
    'what-is-machine-learning',
    E'# What is Machine Learning?\n\nMachine Learning is a subset of artificial intelligence that enables computers to learn from data without being explicitly programmed.\n\n## Key Concepts\n\n1. **Supervised Learning**: Learning from labeled data\n2. **Unsupervised Learning**: Finding patterns in unlabeled data\n3. **Reinforcement Learning**: Learning through trial and error\n\n## Real-World Applications\n\n- Image recognition\n- Natural language processing\n- Recommendation systems\n- Fraud detection\n\n## Getting Started\n\nTo begin your machine learning journey, you need:\n- Basic programming skills (Python recommended)\n- Understanding of basic statistics\n- Curiosity and willingness to learn!\n\nIn the next lesson, we will explore the different types of machine learning in detail.',
    30,
    1,
    true,
    NULL
  ),
  (
    '850e8400-e29b-41d4-a716-446655440002',
    '750e8400-e29b-41d4-a716-446655440001',
    '650e8400-e29b-41d4-a716-446655440001',
    'Types of Machine Learning',
    'types-of-machine-learning',
    E'# Types of Machine Learning\n\nMachine learning algorithms can be categorized into three main types:\n\n## 1. Supervised Learning\n\nSupervised learning uses labeled training data to learn the relationship between input features and output labels.\n\n**Examples:**\n- Classification (spam detection, image recognition)\n- Regression (price prediction, weather forecasting)\n\n## 2. Unsupervised Learning\n\nUnsupervised learning finds hidden patterns in unlabeled data.\n\n**Examples:**\n- Clustering (customer segmentation)\n- Dimensionality reduction (data visualization)\n- Anomaly detection\n\n## 3. Reinforcement Learning\n\nReinforcement learning trains agents to make decisions by rewarding desired behaviors.\n\n**Examples:**\n- Game playing (AlphaGo, Chess engines)\n- Robotics\n- Autonomous vehicles\n\n## Choosing the Right Approach\n\nThe type of machine learning you use depends on:\n- The problem you are solving\n- The data available\n- The desired outcome\n\nNow, test your knowledge with the quiz!',
    30,
    2,
    true,
    '950e8400-e29b-41d4-a716-446655440001'
  )
ON CONFLICT (course_id, slug) DO NOTHING;

-- Questions for ML Basics Quiz
INSERT INTO questions (quiz_id, prompt, choices, correct_index, explanation, points, "order") VALUES
  (
    '950e8400-e29b-41d4-a716-446655440001',
    'What is the main characteristic of supervised learning?',
    ARRAY['It uses labeled training data', 'It finds patterns in unlabeled data', 'It learns through trial and error', 'It requires no data'],
    0,
    'Supervised learning uses labeled training data where both input features and corresponding output labels are provided.',
    1,
    1
  ),
  (
    '950e8400-e29b-41d4-a716-446655440001',
    'Which of the following is an example of unsupervised learning?',
    ARRAY['Email spam detection', 'Customer segmentation', 'House price prediction', 'Image classification'],
    1,
    'Customer segmentation is a clustering task, which is a type of unsupervised learning that groups similar data points together.',
    1,
    2
  ),
  (
    '950e8400-e29b-41d4-a716-446655440001',
    'What type of machine learning is used in game-playing AI like AlphaGo?',
    ARRAY['Supervised Learning', 'Unsupervised Learning', 'Reinforcement Learning', 'Semi-supervised Learning'],
    2,
    'AlphaGo uses reinforcement learning, where the agent learns to make decisions by receiving rewards or penalties for its actions.',
    1,
    3
  ),
  (
    '950e8400-e29b-41d4-a716-446655440001',
    'Which problem would best be solved using regression?',
    ARRAY['Classifying emails as spam or not spam', 'Predicting house prices', 'Grouping customers by behavior', 'Detecting fraudulent transactions'],
    1,
    'Regression is used for predicting continuous numerical values, such as house prices, stock prices, or temperatures.',
    1,
    4
  ),
  (
    '950e8400-e29b-41d4-a716-446655440001',
    'What is a key requirement to start learning machine learning?',
    ARRAY['PhD in mathematics', 'Basic programming skills', 'Expensive hardware', 'Years of experience'],
    1,
    'Basic programming skills (especially Python) are essential to start learning machine learning. Advanced degrees and expensive hardware are not required to begin.',
    1,
    5
  )
ON CONFLICT DO NOTHING;

-- Module 2: Data Structures
INSERT INTO modules (id, course_id, title, "order") VALUES
  ('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440001', 'Data Types and Structures', 2)
ON CONFLICT DO NOTHING;

-- Lessons for Module 2
INSERT INTO lessons (id, module_id, course_id, title, slug, content, duration_minutes, "order", published) VALUES
  (
    '850e8400-e29b-41d4-a716-446655440003',
    '750e8400-e29b-41d4-a716-446655440002',
    '650e8400-e29b-41d4-a716-446655440001',
    'Understanding Data Types',
    'understanding-data-types',
    E'# Understanding Data Types\n\nIn machine learning, understanding your data is crucial for success.\n\n## Common Data Types\n\n### 1. Numerical Data\n- **Continuous**: Temperature, weight, price\n- **Discrete**: Count of items, number of clicks\n\n### 2. Categorical Data\n- **Nominal**: Colors, categories (no order)\n- **Ordinal**: Ratings, education level (has order)\n\n### 3. Text Data\n- Reviews, documents, social media posts\n- Requires special preprocessing techniques\n\n### 4. Image Data\n- Pixel values representing visual information\n- Used in computer vision tasks\n\n### 5. Time Series Data\n- Sequential data points indexed by time\n- Stock prices, weather data, sensor readings\n\n## Data Quality Matters\n\nGood machine learning models require:\n- Clean data (no errors or inconsistencies)\n- Sufficient data (enough examples to learn from)\n- Relevant features (meaningful attributes)\n\nNext, we will learn about data structures used to organize this data.',
    30,
    1,
    true
  ),
  (
    '850e8400-e29b-41d4-a716-446655440004',
    '750e8400-e29b-41d4-a716-446655440002',
    '650e8400-e29b-41d4-a716-446655440001',
    'Working with Pandas DataFrames',
    'working-with-pandas-dataframes',
    E'# Working with Pandas DataFrames\n\nPandas is the most popular library for data manipulation in Python.\n\n## What is a DataFrame?\n\nA DataFrame is a 2-dimensional labeled data structure with columns that can be of different types.\n\n## Basic Operations\n\n### Loading Data\n```python\nimport pandas as pd\n\ndf = pd.read_csv(\"data.csv\")\nprint(df.head())\n```\n\n### Exploring Data\n```python\ndf.info()\ndf.describe()\ndf.shape\n```\n\n### Selecting Data\n```python\ndf[\"column_name\"]\ndf[[\"col1\", \"col2\"]]\ndf[df[\"age\"] > 25]\n```\n\n### Handling Missing Values\n```python\ndf.dropna()\ndf.fillna(value)\ndf.isna().sum()\n```\n\n## Practice Exercise\n\nTry loading a CSV file and:\n1. Display the first 10 rows\n2. Check for missing values\n3. Calculate basic statistics\n4. Filter rows based on a condition\n\nCongratulations on completing Module 2!',
    30,
    2,
    true
  )
ON CONFLICT (course_id, slug) DO NOTHING;

-- =====================================================
-- 3. CREATE INTERMEDIATE COURSE
-- =====================================================

INSERT INTO courses (id, title, slug, summary, description, level, duration_minutes, published) VALUES
  (
    '650e8400-e29b-41d4-a716-446655440002',
    'Deep Learning Fundamentals',
    'deep-learning-fundamentals',
    'Dive into neural networks and deep learning techniques for complex pattern recognition.',
    'Build on your machine learning foundation and explore the world of deep learning. Learn about neural networks, backpropagation, activation functions, and how to build models with modern frameworks.',
    'intermediate',
    120,
    true
  )
ON CONFLICT (slug) DO NOTHING;

INSERT INTO course_tags (course_id, tag_id) VALUES
  ('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002'),
  ('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005'),
  ('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440008')
ON CONFLICT DO NOTHING;

-- Set prerequisite
INSERT INTO course_prerequisites (course_id, prerequisite_course_id) VALUES
  ('650e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Module for Intermediate Course
INSERT INTO modules (id, course_id, title, "order") VALUES
  ('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440002', 'Neural Networks Introduction', 1)
ON CONFLICT DO NOTHING;

-- Lesson for Intermediate Course
INSERT INTO lessons (id, module_id, course_id, title, slug, content, duration_minutes, "order", published) VALUES
  (
    '850e8400-e29b-41d4-a716-446655440005',
    '750e8400-e29b-41d4-a716-446655440003',
    '650e8400-e29b-41d4-a716-446655440002',
    'Introduction to Neural Networks',
    'introduction-to-neural-networks',
    E'# Introduction to Neural Networks\n\nNeural networks are the foundation of modern deep learning.\n\n## What is a Neural Network?\n\nA neural network is a series of algorithms that endeavors to recognize underlying relationships in a set of data through a process that mimics the way the human brain operates.\n\n## Basic Architecture\n\n### Layers\n1. **Input Layer**: Receives the input features\n2. **Hidden Layers**: Process the data\n3. **Output Layer**: Produces the final prediction\n\n### Neurons\nEach neuron:\n- Receives inputs\n- Applies weights\n- Adds a bias\n- Passes through an activation function\n\n## Activation Functions\n\nCommon activation functions:\n- **ReLU**: max(0, x)\n- **Sigmoid**: 1 / (1 + e^(-x))\n- **Tanh**: (e^x - e^(-x)) / (e^x + e^(-x))\n\n## Forward Propagation\n\nThe process of passing data through the network:\n1. Input layer receives features\n2. Each hidden layer transforms the data\n3. Output layer produces predictions\n\n## Training Process\n\n1. Initialize weights randomly\n2. Forward propagation (make predictions)\n3. Calculate loss (error)\n4. Backpropagation (update weights)\n5. Repeat until convergence\n\nIn the next lessons, we will implement neural networks using TensorFlow!',
    40,
    1,
    true
  )
ON CONFLICT (course_id, slug) DO NOTHING;

-- =====================================================
-- 4. CREATE BLOG POSTS
-- =====================================================

INSERT INTO blog_posts (id, title, slug, excerpt, content, published, published_at) VALUES
  (
    'a50e8400-e29b-41d4-a716-446655440001',
    'Understanding the Bias-Variance Tradeoff',
    'understanding-bias-variance-tradeoff',
    'Learn about one of the most important concepts in machine learning and how to balance model complexity.',
    E'# Understanding the Bias-Variance Tradeoff\n\nThe bias-variance tradeoff is a fundamental concept in machine learning that every data scientist must understand.\n\n## What is Bias?\n\nBias refers to the error introduced by approximating a real-world problem with a simplified model. High bias can cause the model to miss relevant relationships between features and outputs (underfitting).\n\n## What is Variance?\n\nVariance refers to the model''s sensitivity to small fluctuations in the training data. High variance can cause the model to model random noise in the data (overfitting).\n\n## The Tradeoff\n\nAs you decrease bias, you typically increase variance, and vice versa. The goal is to find the sweet spot that minimizes total error.\n\n## How to Balance\n\n1. **Cross-validation**: Test your model on unseen data\n2. **Regularization**: Add penalties for complexity\n3. **Ensemble methods**: Combine multiple models\n4. **Feature selection**: Choose relevant features\n\n## Conclusion\n\nUnderstanding this tradeoff helps you build models that generalize well to new data.',
    true,
    NOW()
  ),
  (
    'a50e8400-e29b-41d4-a716-446655440002',
    'What is Overfitting and How to Prevent It',
    'what-is-overfitting-and-how-to-prevent-it',
    'Overfitting is a common problem in machine learning. Learn what it is and how to combat it effectively.',
    E'# What is Overfitting and How to Prevent It\n\nOverfitting occurs when a model learns the training data too well, including its noise and outliers, resulting in poor performance on new, unseen data.\n\n## Signs of Overfitting\n\n- High accuracy on training data\n- Poor accuracy on validation/test data\n- Model performs worse as you add more features\n- Learning curves show divergence\n\n## Causes of Overfitting\n\n1. **Too complex model**: Too many parameters\n2. **Too little data**: Not enough examples to learn from\n3. **Training too long**: Model memorizes training data\n4. **No regularization**: No constraints on model complexity\n\n## Prevention Strategies\n\n### 1. More Training Data\nThe simplest solution - more diverse data helps the model generalize.\n\n### 2. Cross-Validation\nUse k-fold cross-validation to ensure your model performs well on different subsets of data.\n\n### 3. Regularization\n- **L1 (Lasso)**: Adds absolute value of coefficients as penalty\n- **L2 (Ridge)**: Adds squared magnitude of coefficients as penalty\n\n### 4. Early Stopping\nMonitor validation loss and stop training when it starts increasing.\n\n### 5. Dropout (Neural Networks)\nRandomly drop neurons during training to prevent co-adaptation.\n\n### 6. Data Augmentation\nCreate synthetic training examples from existing data.\n\n### 7. Simplify the Model\nReduce the number of features or use a less complex architecture.\n\n## Conclusion\n\nOverfitting is common but manageable. Use these techniques to build models that generalize well!',
    true,
    NOW()
  )
ON CONFLICT (slug) DO NOTHING;

-- Blog post tags
INSERT INTO blog_post_tags (blog_post_id, tag_id) VALUES
  ('a50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
  ('a50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. CREATE RESOURCES
-- =====================================================

INSERT INTO resources (id, title, url, description, resource_type) VALUES
  (
    'b50e8400-e29b-41d4-a716-446655440001',
    'Kaggle Datasets',
    'https://www.kaggle.com/datasets',
    'Explore thousands of public datasets for machine learning projects. Find data on topics ranging from healthcare to finance.',
    'dataset'
  ),
  (
    'b50e8400-e29b-41d4-a716-446655440002',
    'Attention Is All You Need',
    'https://arxiv.org/abs/1706.03762',
    'The groundbreaking paper that introduced the Transformer architecture, revolutionizing natural language processing.',
    'paper'
  ),
  (
    'b50e8400-e29b-41d4-a716-446655440003',
    'TensorFlow Playground',
    'https://playground.tensorflow.org',
    'An interactive visualization tool to understand neural networks by playing with different architectures and datasets in your browser.',
    'tool'
  )
ON CONFLICT DO NOTHING;

-- Resource tags
INSERT INTO resource_tags (resource_id, tag_id) VALUES
  ('b50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006'),
  ('b50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003'),
  ('b50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002'),
  ('b50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008')
ON CONFLICT DO NOTHING;