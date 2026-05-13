<?php
declare(strict_types=1);
require __DIR__ . '/../src/bootstrap.php';
end_session($ENV);
header('Location: /tuner/login.php');
