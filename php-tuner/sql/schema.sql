-- Devstars Jersey: Beach Aware — PHP tuner schema
-- Charset: utf8mb4 so French/Norman names render correctly.
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS beach_biases (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  beach_id          VARCHAR(64)  NOT NULL,
  activity          VARCHAR(32)  NOT NULL,
  bias              SMALLINT     NOT NULL DEFAULT 0,
  reasons           JSON         NOT NULL,
  prohibited        TINYINT(1)   NOT NULL DEFAULT 0,
  prohibited_reason VARCHAR(255)         DEFAULT NULL,
  updated_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updated_by_ip     VARCHAR(45)          DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_beach_activity (beach_id, activity),
  KEY ix_activity (activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS admin_sessions (
  id          CHAR(64)    NOT NULL,
  created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at  TIMESTAMP   NOT NULL,
  ip          VARCHAR(45)          DEFAULT NULL,
  PRIMARY KEY (id),
  KEY ix_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional: simple audit log so you can see who/what/when changed.
CREATE TABLE IF NOT EXISTS bias_audit (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  beach_id     VARCHAR(64)  NOT NULL,
  activity     VARCHAR(32)  NOT NULL,
  bias_before  SMALLINT              DEFAULT NULL,
  bias_after   SMALLINT     NOT NULL,
  prohibited_before TINYINT(1)       DEFAULT NULL,
  prohibited_after  TINYINT(1) NOT NULL,
  changed_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  changed_ip   VARCHAR(45)           DEFAULT NULL,
  PRIMARY KEY (id),
  KEY ix_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- Auto-generated beach × activity seed data
-- Generated from client/src/data/beaches.ts

INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'swimming', -10, '["Locally regarded as a good family swim spot"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'paddling', -10, '["Locally regarded as a good spot for small children"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'paddleboarding', -15, '["Locally regarded as one of the best SUP spots on the island"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'kayaking', -10, '["Locally regarded as a good kayak launch — sheltered and easy access"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'surfing', 35, '["Sheltered south coast — rarely a surf break"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'bodyboarding', 5, '["Generally too sheltered for bodyboard waves"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'kitesurfing', 60, '["Limited launch space and dog walkers; not a kite venue"]', 1, 'Local consensus is no — sheltered family beach with dog walkers')
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('ouaisne', 'sailing', 25, '["No slipway; vessels generally launch from St Brelade''s instead"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'swimming', -10, '["Locally regarded as a good spot for this activity","Best swum near HW; warm shallow water"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'paddling', -15, '["Locally regarded as one of the best paddling beaches for small kids"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'paddleboarding', 0, '["Calm sheltered water near HW"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'kayaking', 10, '["Strong tidal stream offshore — stay close in"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'surfing', 40, '["Not a surf beach — south coast and reef-protected"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'bodyboarding', 25, '["Sheltered south coast — usually too flat for bodyboarding"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'kitesurfing', 60, '["No kite-launch space and busy with rock-poolers"]', 1, 'No kite-launch space; very mixed beach use')
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('green-island', 'sailing', 25, '["No slipway; very fast-flooding flats"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-ouens', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-ouens', 'paddleboarding', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-ouens', 'kayaking', 45, '["powerful rip currents make headland exit dangerous"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-ouens', 'kitesurfing', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('plemont', 'swimming', 15, '["Locally regarded as a good spot for this activity","Beach largely covered at HW – swim window limited"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('plemont', 'paddleboarding', 70, '["fast-moving tidal currents near headlands","Limited launch window around LW only"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('plemont', 'kayaking', 25, '["Beach access poor at HW"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('plemont', 'kitesurfing', 45, '["cliff-bound cove with no rigging room"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('plemont', 'sailing', 70, '["inaccessible to vessels at LW","No vessel access at LW"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('greve-de-lecq', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('greve-de-lecq', 'paddleboarding', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('greve-de-lecq', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('greve-de-lecq', 'kitesurfing', 70, '["too small a beach footprint and headland cliffs block consistent wind","Tight kite-launch space (~100 m)"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bonne-nuit', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bonne-nuit', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bonne-nuit', 'kitesurfing', 45, '["tiny harbour with no kite space and moored boats"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bonne-nuit', 'sailing', 25, '["No slipway / not a recognised sailing venue"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bouley-bay', 'swimming', 15, '["Locally regarded as a good spot for this activity","Steep beach drops to deep water – competent swimmers only"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bouley-bay', 'paddleboarding', 25, '["Kelp rock bottom – tricky launch"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bouley-bay', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('bouley-bay', 'kitesurfing', 70, '["cliff-hemmed cove with no launch space and no consistent wind window","Steep shore – no shallow wade-out for self-rescue","Kelp rock bottom – risk to lines and kite"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('rozel', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('rozel', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('rozel', 'kitesurfing', 45, '["tiny enclosed harbour with moored boats and no rigging space"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('rozel', 'sailing', 25, '["No slipway / not a recognised sailing venue"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-catherines', 'paddleboarding', 15, '["Locally regarded as a good spot for this activity","Rock reef bottom – tricky launch"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-catherines', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-catherines', 'kitesurfing', 70, '["no open beach — rocky intertidal and breakwater structure only","Rock reef bottom – risk to lines and kite"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-catherines', 'sailing', 15, '["Locally regarded as a good spot for this activity","No slipway / not a recognised sailing venue"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('archirondel', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('archirondel', 'kitesurfing', 45, '["tiny cove with no kite space"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('anne-port', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('anne-port', 'kitesurfing', 45, '["east-facing enclosed cove with cliffs, zero rigging space"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('royal-bay-grouville', 'swimming', 15, '["Locally regarded as a good spot for this activity","Fast-flooding tidal flats – cut-off risk for paddlers"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('royal-bay-grouville', 'paddleboarding', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('royal-bay-grouville', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('royal-bay-grouville', 'kitesurfing', 45, '["no dedicated kite beach and strong motorised watersports presence in summer"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('royal-bay-grouville', 'sailing', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('havre-des-pas', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('havre-des-pas', 'kitesurfing', 45, '["urban promenade beach with no kite space"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-brelades', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-brelades', 'paddleboarding', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-brelades', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('st-brelades', 'kitesurfing', 60, '["designated swim and watersports zone in bay centre — kite launch prohibited"]', 1, 'designated swim and watersports zone in bay centre — kite launch prohibited')
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('beauport', 'swimming', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('beauport', 'kayaking', -10, '["Locally regarded as a good spot for this activity"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('beauport', 'kitesurfing', 45, '["three-sided cliff bay with no wind window and no rigging space"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('portelet', 'swimming', 15, '["Locally regarded as a good spot for this activity","Beach largely covered at HW – swim window limited"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('portelet', 'paddleboarding', 25, '["Limited launch window around LW only"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('portelet', 'kayaking', 25, '["Beach access poor at HW"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('portelet', 'kitesurfing', 45, '["cliff-enclosed cove with no rigging space"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
INSERT INTO beach_biases (beach_id, activity, bias, reasons, prohibited, prohibited_reason)
  VALUES ('portelet', 'sailing', 70, '["no vessel access at LW","No vessel access at LW"]', 0, NULL)
  ON DUPLICATE KEY UPDATE bias=VALUES(bias), reasons=VALUES(reasons), prohibited=VALUES(prohibited), prohibited_reason=VALUES(prohibited_reason);
