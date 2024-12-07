using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace Custom2DGameEngine
{
    // Base class for game objects
    public abstract class GameObject
    {
        public float X { get; set; }
        public float Y { get; set; }
        public float Width { get; set; }
        public float Height { get; set; }
        public bool IsActive { get; set; } = true;

        public abstract void Update(float deltaTime);
        public abstract void Render(Graphics graphics);
    }

    // Simple rectangle game object example
    public class RectangleObject : GameObject
    {
        public Color Color { get; set; }

        public override void Update(float deltaTime)
        {
            // Example movement: move right continuously
            X += 100 * deltaTime;
        }

        public override void Render(Graphics graphics)
        {
            using (Brush brush = new SolidBrush(Color))
            {
                graphics.FillRectangle(brush, X, Y, Width, Height);
            }
        }
    }

    // Game engine class
    public class GameEngine : Form
    {
        private List<GameObject> gameObjects = new List<GameObject>();
        private bool isRunning = true;
        private float lastFrameTime;
        private System.Windows.Forms.Timer gameTimer;

        public GameEngine(int width, int height, string title)
        {
            this.Width = width;
            this.Height = height;
            this.Text = title;

            // Initialize game timer
            gameTimer = new System.Windows.Forms.Timer();
            gameTimer.Interval = 16; // Approx. 60 FPS
            gameTimer.Tick += GameLoop;
            gameTimer.Start();

            this.DoubleBuffered = true; // Reduce flicker
        }

        public void AddGameObject(GameObject obj)
        {
            gameObjects.Add(obj);
        }

        public void Start()
        {
            Application.Run(this);
        }

        private void GameLoop(object sender, EventArgs e)
        {
            if (!isRunning) return;

            float currentTime = Environment.TickCount / 1000.0f;
            float deltaTime = currentTime - lastFrameTime;
            lastFrameTime = currentTime;

            Update(deltaTime);
            Invalidate(); // Triggers Paint event for rendering
        }

        private void Update(float deltaTime)
        {
            foreach (var obj in gameObjects)
            {
                if (obj.IsActive)
                {
                    obj.Update(deltaTime);
                }
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            var graphics = e.Graphics;

            foreach (var obj in gameObjects)
            {
                if (obj.IsActive)
                {
                    obj.Render(graphics);
                }
            }
        }

        protected override void OnKeyDown(KeyEventArgs e)
        {
            base.OnKeyDown(e);

            if (e.KeyCode == Keys.Escape)
            {
                isRunning = false;
                this.Close();
            }
        }
    }

    // Example game implementation
    class Program
    {
        static void Main(string[] args)
        {
            GameEngine engine = new GameEngine(800, 600, "Custom 2D Game Engine");

            RectangleObject player = new RectangleObject
            {
                X = 50,
                Y = 100,
                Width = 50,
                Height = 50,
                Color = Color.Red
            };

            engine.AddGameObject(player);

            engine.Start();
        }
    }
}
