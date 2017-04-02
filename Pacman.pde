PacmanRoute pac; //<>//
int rows=30;
int cols=30;


void setup()
{
  fill(255, 255, 255);
  size(640, 650);
  pac=new PacmanRoute();
  pac.Init(this.rows, this.cols); //<>//
}
void draw() {
  for (Cell[] colCells : pac.Map) {
    for (Cell cell : colCells) {

      switch(cell.Type) {
      case eCellType.LOCKED:
        fill(0, 0, 0);
        break; 
      case eCellType.CURRENT:
        fill(0, 255, 26);
        break; 
      default:      
        fill(255, 255, 255);
        break;
      }
      rect(cell.X * 20, cell.Y * 20, 20, 20);
    }
  }
  
  for (Cell cell : pac.GoodRoute) {
    fill(0, 255, 26);
    rect(cell.X * 20, cell.Y * 20, 20, 20);
  }
}

void mousePressed() {
  if  (mouseX>this.cols*20||mouseY>this.rows*20) {
    return;
  }

  int X=mouseX/20;
  int Y=mouseY/20;

  Cell cell=pac.FindCell(X, Y);
  pac.FindRoute(cell);
}


class  eCellType {
  public static final int DEFAULT=1;
  public static final int  CURRENT=2;
  public static final int LOCKED=3;
  public static final int ROUTED=4;
}


class Cell 
{  
  public int X;
  public int Y;
  public int Type;

  Cell() {
    Type=eCellType.DEFAULT;
  }
}


class Node {
  Node(Cell cell) {
    this.Cell = cell;
  }

  public Cell Cell;
  public Node PreviousNode;

  public float h;
  public float g;
  public float f;
}


class PacmanRoute {
  public Cell[][] Map;
  ArrayList<Cell> GoodRoute;

  Cell currentCell;
  ArrayList<Node> openNodes;
  ArrayList<Node> closeNodes;

  int rows;
  int cols;
  PacmanRoute() {
  }

  void Init(int rows, int cols) {
    this.RandomMap(rows, cols);
  }

  void RandomMap(int rows, int cols) {
    this.rows=rows;
    this.cols=cols;
    this.Map=new Cell[rows][cols];

    for (int r = 0; r < rows; r++) {
      Cell[] colCells =new Cell[cols];
      for (int c = 0; c < cols; c++) {
        Cell cell = new Cell();
        cell.X = c;
        cell.Y = r;
        colCells[c]=cell;
      }
      this.Map[r]=colCells;
    }


    int lockCell = (rows * cols) / 6;
    for (int i = 0; i < lockCell; i++) {
      int ranX = int(random(1, rows-1));
      int ranY = int(random(1, cols-1));
      Cell lockedCell= this.FindCell(ranX, ranY); 
      lockedCell.Type=eCellType.LOCKED;
    }

    this.GoodRoute=new ArrayList<Cell>();
    this.currentCell = this.FindCell(0, 0);
    this.currentCell.Type = eCellType.CURRENT;
  }

  void FindRoute(Cell cellTarget) {    
    if (cellTarget.Type==eCellType.LOCKED|| cellTarget.Type==eCellType.CURRENT) {
      return;
    }

    this.openNodes=new ArrayList<Node>();
    this.closeNodes=new ArrayList<Node>();
    this.GoodRoute=new ArrayList<Cell>();

    Node currentNode = new Node(this.currentCell);
    currentNode.g = 0;
    currentNode.h = this.distance(this.currentCell, cellTarget);
    currentNode.f = currentNode.g + currentNode.h;
    currentNode.PreviousNode=null;

    this.openNodes.add(currentNode);
    while (this.openNodes.size() != 0) {

      int openNodesSize=this.openNodes.size();
      int currentIndex = 0;
      Node current = this.openNodes.get(currentIndex);

      for (int i = 0; i < openNodesSize; i++) {
        if (this.openNodes.get(i).f<current.f ) {     
          current = this.openNodes.get(i);
          currentIndex = i;
        }
      }

      this.openNodes.remove(currentIndex);
      this.closeNodes.add(current);

      if (current.Cell.X == cellTarget.X && current.Cell.Y == cellTarget.Y) {
        while (current.g!=0) {
          this.GoodRoute.add(current.Cell);
          current=current.PreviousNode;
        }
        this.GoodRoute.add(this.currentCell);
        cellTarget.Type=eCellType.CURRENT;
        currentCell.Type=eCellType.DEFAULT;
        this.currentCell=cellTarget;

        return;
      } else {
        this.enQueue(current, cellTarget);
      }
    }
  }

  Cell FindCell(int x, int y) {
    return this.Map[y][x];
  }

  void enQueue(Node node, Cell cellTarget) {
    int[] xCoordinates = {1, 0, -1, 0};
    int[] yCoordinates = {0, 1, 0, -1};

    for (int i = 0; i < 4; i++) {
      int x = node.Cell.X + xCoordinates[i];
      int y = node.Cell.Y + yCoordinates[i];

      if (x < 0 || x >= this.cols || y < 0 || y >= this.rows) {               
        continue;
      }

      Cell nextCell = this.FindCell(x, y);
      if (nextCell.Type == eCellType.LOCKED) {
        continue;
      }

      boolean checkedNode=false;
      for (int c = 0; c < this.closeNodes.size(); c++) {
        if (this.closeNodes.get(c).Cell.X == nextCell.X && this.closeNodes.get(c).Cell.Y == nextCell.Y) {
          checkedNode=true;
          break;
        }
      }

      if (!checkedNode) {
        for (int o = 0; o < this.openNodes.size(); o++) {
          if (this.openNodes.get(o).Cell.X == nextCell.X && this.openNodes.get(o).Cell.Y == nextCell.Y) {
            checkedNode=true;
            break;
          }
        }
      }

      if (!checkedNode) {
        float temp_g = node.g + this.distance(node.Cell, nextCell);
        Node newNode = new Node(nextCell);
        newNode.PreviousNode = node;
        newNode.g = temp_g;
        newNode.h = this.distance(nextCell, cellTarget);
        newNode.f = newNode.g + newNode.h;
        this.openNodes.add(newNode);
      }
    }
  }

  float distance(Cell source, Cell target) {
    return Math.abs(source.X - target.X) + Math.abs(source.Y - target.Y);
  }
}