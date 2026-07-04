enum ConnectorCategory {
  code,
  communication,
  data,
  design,
  financialServices,
  health,
  lifeSciences,
  productivity,
  salesAndMarketing,
}

class Connector {
  final String id;
  final String name;
  final String description;
  final ConnectorCategory category;
  final int popularityRank;
  final bool isInteractive;
  final bool isNew;
  final bool isConnected;

  const Connector({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.popularityRank,
    this.isInteractive = false,
    this.isNew = false,
    this.isConnected = false,
  });

  Connector copyWith({bool? isConnected}) => Connector(
        id: id,
        name: name,
        description: description,
        category: category,
        popularityRank: popularityRank,
        isInteractive: isInteractive,
        isNew: isNew,
        isConnected: isConnected ?? this.isConnected,
      );
}

class ConnectorDirectory {
  static const List<Connector> all = [
    Connector(id: 'canva', name: 'Canva', description: 'Search, create, autofill, and export Canva designs', category: ConnectorCategory.design, popularityRank: 2, isInteractive: true),
    Connector(id: 'figma', name: 'Figma', description: 'Generate diagrams and better code from Figma context', category: ConnectorCategory.design, popularityRank: 3, isInteractive: true),
    Connector(id: 'microsoft365', name: 'Microsoft 365', description: "Access your company's SharePoint, OneDrive, Outlook, and Teams directly in Tern", category: ConnectorCategory.communication, popularityRank: 7),
    Connector(id: 'asana', name: 'Asana', description: 'Connect to Asana to coordinate tasks, projects, and goals', category: ConnectorCategory.communication, popularityRank: 8, isInteractive: true),
    Connector(id: 'gmail', name: 'Gmail', description: 'Draft replies, summarize threads, & search your inbox', category: ConnectorCategory.communication, popularityRank: 9),
    Connector(id: 'notion', name: 'Notion', description: 'Connect your Notion workspace to search, update, and power workflows across tools', category: ConnectorCategory.code, popularityRank: 10),
    Connector(id: 'atlassian_rovo', name: 'Atlassian Rovo', description: 'Access Jira & Confluence from Tern', category: ConnectorCategory.code, popularityRank: 11),
    Connector(id: 'miro', name: 'Miro', description: 'Access and create new content on Miro boards', category: ConnectorCategory.design, popularityRank: 17),
    Connector(id: 'microsoft_learn', name: 'Microsoft Learn', description: 'Search trusted Microsoft docs to power your development', category: ConnectorCategory.code, popularityRank: 25),
    Connector(id: 'replit', name: 'Replit', description: 'Turn ideas into apps and websites instantly', category: ConnectorCategory.code, popularityRank: 0, isInteractive: true, isNew: true),
    Connector(id: 'slack', name: 'Slack', description: 'Send messages, create canvases, and fetch Slack data', category: ConnectorCategory.communication, popularityRank: 14, isInteractive: true),
    Connector(id: 'intercom', name: 'Intercom', description: 'Access to Intercom data for better customer insights', category: ConnectorCategory.communication, popularityRank: 22),
    Connector(id: 'zapier', name: 'Zapier', description: 'Automate workflows across thousands of apps via conversation', category: ConnectorCategory.communication, popularityRank: 36),
    Connector(id: 'vercel', name: 'Vercel', description: 'Analyze, debug, and manage projects and deployments', category: ConnectorCategory.code, popularityRank: 30),
    Connector(id: 'lovable', name: 'Lovable', description: 'Build, iterate, inspect, and deploy Lovable apps', category: ConnectorCategory.code, popularityRank: 0, isInteractive: true, isNew: true),
    Connector(id: 'supabase', name: 'Supabase', description: 'Manage databases, authentication, and storage', category: ConnectorCategory.data, popularityRank: 48),
    Connector(id: 'sentry', name: 'Sentry', description: 'Search, query, and debug errors intelligently', category: ConnectorCategory.code, popularityRank: 52),
    Connector(id: 'google_drive', name: 'Google Drive', description: 'Search, read, and upload files instantly', category: ConnectorCategory.data, popularityRank: 12),
    Connector(id: 'box', name: 'Box', description: 'Search, edit and get insights on your Box content', category: ConnectorCategory.data, popularityRank: 24, isInteractive: true),
    Connector(id: 'airtable', name: 'Airtable', description: 'Bring your structured data to Tern', category: ConnectorCategory.data, popularityRank: 41),
    Connector(id: 'hubspot', name: 'HubSpot', description: 'CRM context for every answer, insight, and action', category: ConnectorCategory.salesAndMarketing, popularityRank: 15),
    Connector(id: 'monday', name: 'monday.com', description: 'Manage projects, boards, and workflows in monday.com', category: ConnectorCategory.salesAndMarketing, popularityRank: 16, isInteractive: true),
    Connector(id: 'gamma', name: 'Gamma', description: 'Create presentations, docs, socials, and sites with AI', category: ConnectorCategory.salesAndMarketing, popularityRank: 46, isInteractive: true),
    Connector(id: 'zoominfo', name: 'ZoomInfo', description: 'Enrich contacts & accounts with GTM intelligence', category: ConnectorCategory.salesAndMarketing, popularityRank: 47),
    Connector(id: 'semrush', name: 'Semrush', description: 'SEO, competitor research, and traffic analysis', category: ConnectorCategory.salesAndMarketing, popularityRank: 57),
    Connector(id: 'stripe', name: 'Stripe', description: 'Payment processing and financial infrastructure tools', category: ConnectorCategory.financialServices, popularityRank: 97),
    Connector(id: 'xero', name: 'Xero', description: 'Manage accounting directly from Tern', category: ConnectorCategory.financialServices, popularityRank: 146, isInteractive: true),
    Connector(id: 'pubmed', name: 'PubMed', description: 'Search biomedical literature from PubMed', category: ConnectorCategory.lifeSciences, popularityRank: 83),
    Connector(id: 'clinical_trials', name: 'Clinical Trials', description: 'Access ClinicalTrials.gov data', category: ConnectorCategory.lifeSciences, popularityRank: 186),
  ];

  static List<Connector> byCategory(ConnectorCategory? category) {
    if (category == null) return all;
    return all.where((c) => c.category == category).toList();
  }

  static String categoryLabel(ConnectorCategory category) {
    switch (category) {
      case ConnectorCategory.code:
        return 'Code';
      case ConnectorCategory.communication:
        return 'Communication';
      case ConnectorCategory.data:
        return 'Data';
      case ConnectorCategory.design:
        return 'Design';
      case ConnectorCategory.financialServices:
        return 'Financial services';
      case ConnectorCategory.health:
        return 'Health';
      case ConnectorCategory.lifeSciences:
        return 'Life sciences';
      case ConnectorCategory.productivity:
        return 'Productivity';
      case ConnectorCategory.salesAndMarketing:
        return 'Sales and marketing';
    }
  }
}
