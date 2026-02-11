export interface ElementAnchor {
  selector: string;
  componentName?: string;
  filePath?: string;
  boundingRect: DOMRect;
  textContent?: string;
  tagName: string;
  htmlSnapshot: string;
}

export interface Comment {
  id: string;
  anchor: ElementAnchor;
  text: string;
  status: "active" | "outdated";
  createdAt: string;
  updatedAt: string;
}

export interface CommentPage {
  version: number;
  pathname: string;
  updatedAt: string;
  comments: Comment[];
}
