import { describe, expect, it } from "vitest";
import { init } from "./index";
import type {
  DomAnchor,
  SourceAnchor,
  Author,
  Comment,
  CommentFile,
} from "./types";

describe("DomAnchor", () => {
  it("satisfies the interface", () => {
    const anchor: DomAnchor = {
      selector: "#btn",
      textContent: "Click me",
      tagName: "button",
      boundingRect: { x: 0, y: 0, width: 100, height: 32 },
      htmlSnapshot: "<button>Click me</button>",
    };
    expect(anchor.selector).toBe("#btn");
    expect(anchor.textContent).toBe("Click me");
  });
});

describe("SourceAnchor", () => {
  it("satisfies the interface with all fields", () => {
    const anchor: SourceAnchor = {
      filePath: "src/components/LoginButton.tsx",
      componentName: "LoginButton",
      lineNumber: 42,
      commitSha: "abc123def456",
    };
    expect(anchor.filePath).toBe("src/components/LoginButton.tsx");
  });

  it("allows null for componentName and lineNumber", () => {
    const anchor: SourceAnchor = {
      filePath: "src/App.tsx",
      componentName: null,
      lineNumber: null,
      commitSha: "abc123def456",
    };
    expect(anchor.componentName).toBeNull();
  });
});

describe("Author", () => {
  it("represents a git-config author", () => {
    const author: Author = {
      name: "Alice",
      email: "alice@example.com",
      avatarUrl: null,
      source: "git-config",
    };
    expect(author.source).toBe("git-config");
    expect(author.avatarUrl).toBeNull();
  });

  it("represents a github author", () => {
    const author: Author = {
      name: "Bob",
      email: "bob@example.com",
      avatarUrl: "https://avatars.githubusercontent.com/u/12345",
      source: "github",
    };
    expect(author.source).toBe("github");
    expect(author.avatarUrl).toBeTruthy();
  });
});

describe("Comment", () => {
  it("satisfies the interface with domAnchor only", () => {
    const comment: Comment = {
      id: "abc123def456",
      text: "This button should be red",
      branch: "main",
      domAnchor: {
        selector: "button.primary",
        textContent: "Submit",
        tagName: "button",
        boundingRect: { x: 100, y: 200, width: 80, height: 32 },
        htmlSnapshot: '<button class="primary">Submit</button>',
      },
      sourceAnchor: null,
      author: {
        name: "Alice",
        email: "alice@example.com",
        avatarUrl: null,
        source: "git-config",
      },
      status: "active",
      createdAt: "2025-02-11T10:00:00Z",
      updatedAt: "2025-02-11T10:00:00Z",
    };
    expect(comment.status).toBe("active");
    expect(comment.sourceAnchor).toBeNull();
  });

  it("supports resolved status", () => {
    const comment: Comment = {
      id: "xyz789",
      text: "Fixed",
      branch: "feature/auth",
      domAnchor: {
        selector: "#header",
        textContent: "Hello",
        tagName: "h1",
        boundingRect: { x: 0, y: 0, width: 500, height: 48 },
        htmlSnapshot: "<h1>Hello</h1>",
      },
      sourceAnchor: {
        filePath: "src/Header.tsx",
        componentName: "Header",
        lineNumber: 10,
        commitSha: "def456",
      },
      author: {
        name: "Bob",
        email: "bob@example.com",
        avatarUrl: "https://avatars.githubusercontent.com/u/12345",
        source: "github",
      },
      status: "resolved",
      createdAt: "2025-02-10T10:00:00Z",
      updatedAt: "2025-02-11T10:00:00Z",
    };
    expect(comment.status).toBe("resolved");
    expect(comment.sourceAnchor?.filePath).toBe("src/Header.tsx");
  });
});

describe("CommentFile", () => {
  it("satisfies the interface", () => {
    const file: CommentFile = {
      version: 1,
      projectId: "my-app",
      pathname: "/dashboard",
      comments: [],
    };
    expect(file.version).toBe(1);
    expect(file.comments).toHaveLength(0);
  });
});

describe("init", () => {
  it("is exported as a function", () => {
    expect(typeof init).toBe("function");
  });
});
