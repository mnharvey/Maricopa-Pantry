python3 << 'PYEOF'
path = '/home/bitnami/l6i-server/server.js'
with open(path, 'r') as f:
    content = f.read()

if '/pantry/data' in content:
    print("Pantry data endpoints already present — skipping insert.")
else:
    pantry_data_code = '''
// ============ MARICOPA PANTRY DATA STORE ============
const PANTRY_DATA_FILE = '/home/bitnami/l6i-server/pantry-data.json';

function loadPantryData() {
  try { return JSON.parse(fs.readFileSync(PANTRY_DATA_FILE, 'utf8')); }
  catch (e) { return { inventory: [], intake: [], waste: [], updated: null }; }
}
function savePantryData(data) {
  data.updated = new Date().toISOString();
  fs.writeFileSync(PANTRY_DATA_FILE, JSON.stringify(data, null, 2));
}

// GET all pantry inventory data (stock, intake, waste)
app.get('/pantry/data', (req, res) => {
  try {
    res.json(loadPantryData());
  } catch (err) {
    console.error('[pantry/data GET]', err.message);
    res.status(500).json({ error: err.message });
  }
});

// POST: replace the whole pantry data store (inventory + intake + waste)
app.post('/pantry/data', (req, res) => {
  try {
    const { inventory, intake, waste } = req.body;
    const data = {
      inventory: Array.isArray(inventory) ? inventory : [],
      intake: Array.isArray(intake) ? intake : [],
      waste: Array.isArray(waste) ? waste : []
    };
    savePantryData(data);
    res.json({ status: 'ok', counts: { inventory: data.inventory.length, intake: data.intake.length, waste: data.waste.length }, updated: data.updated });
  } catch (err) {
    console.error('[pantry/data POST]', err.message);
    res.status(500).json({ error: err.message });
  }
});
// ============ END MARICOPA PANTRY DATA STORE ============

'''

    anchor = '\nhttps.createServer'
    idx = content.rfind(anchor)
    if idx == -1:
        print("ERROR: could not find https.createServer anchor. No changes made.")
    else:
        content = content[:idx] + '\n' + pantry_data_code + content[idx:]
        with open(path, 'w') as f:
            f.write(content)
        print("Inserted pantry DATA endpoints before https.createServer.")
PYEOF
